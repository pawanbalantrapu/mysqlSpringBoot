DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenJavaModelAllTabs`(
    in pPackageName varchar
(255),
    in pSchemaName VARCHAR
(255)
)
BEGIN


BLOCK1: BEGIN
DECLARE vTabName varchar    (255);
DECLARE v_finished_out INTEGER DEFAULT 0;
DEClARE tab_cursor CURSOR FOR
select
    distinct table_name
from
    information_schema.COLUMNS
where
    TABLE_SCHEMA = pSchemaName;

DECLARE CONTINUE HANDLER FOR NOT FOUND
SET    v_finished_out = 1;

OPEN tab_cursor;
get_tab: LOOP
FETCH tab_cursor INTO vTabName;

IF v_finished_out = 1 THEN LEAVE get_tab;
END IF;
	
   BLOCK2:BEGIN
   
   DECLARE vClassName varchar(255);
		declare vClassGetSet mediumtext;
		declare vClassPrivate mediumtext;
		declare v_codeChunk_pri_var varchar(1024);
		declare v_codeChunk_pub_get varchar(1024);
		declare v_codeChunk_pub_set varchar(1024);
        DECLARE v_opfile varchar(255);

		DECLARE v_finished INTEGER DEFAULT 0;
		DEClARE code_cursor CURSOR FOR
		SELECT
			pri_var,
			pub_get,
			pub_set
		FROM
			temp1;
		DECLARE CONTINUE HANDLER FOR NOT FOUND  SET    v_finished= 1;
			
			set	vClassGetSet= '';

		/* Make class name*/
	/*	SELECT
			(
						CASE
							WHEN col1 = col2 THEN col1
							ELSE concat(col1, col2)
						END
					) 	into vClassName
		FROM
			(
						SELECT
				CONCAT(
								UCASE(MID(ColumnName1, 1, 1)),
								LCASE(MID(ColumnName1, 2))					) as col1,
				CONCAT(
								UCASE(MID(ColumnName2, 1, 1)),
								LCASE(MID(ColumnName2, 2))					) as col2
			FROM
				(
								SELECT
					SUBSTRING_INDEX(vTabName, '_', -1) as ColumnName2,
					SUBSTRING_INDEX(vTabName, '_', 1) as ColumnName1
							) A
					) B;
*/
SELECT proper_case(vTabName) INTO vClassName;
		drop table if exists java_class;

		/*store all properties into temp table*/
		CREATE TEMPORARY TABLE
		IF NOT EXISTS temp1 ENGINE = MyISAM as
		(
					select
            concat('\t@Column(name="',COLUMN_NAME,'")\n','\tprivate ', ColumnType, ' ', FieldName, ';\n') pri_var, 
			concat(
							'public ',
							ColumnType,
							' get',
							FieldName,
							'(){\n\t\t return _',
							FieldName,
							';\n\t}'				) pub_get,
			concat(
							'public void ',
							' set',
							FieldName,
							'( ',
							ColumnType,
							' value){\n\t\t _',
							FieldName,
							' = value;\n\t}'		) pub_set
		FROM
			(
							SELECT
				camelCase(COLUMN_NAME)AS FieldName,
				case
									DATA_TYPE
									when 'bigint' then 'long'
									when 'binary' then 'byte[]'
									when 'bit' then 'bool'
									when 'char' then 'String'
									when 'date' then 'Date'
									when 'datetime' then 'Date'
									when 'datetime2' then 'Date'
									when 'decimal' then 'decimal'
									when 'float' then 'float'
									when 'image' then 'byte[]'
									when 'blob' then 'byte[]'
									when 'int' then 'int'
									when 'money' then 'decimal'
									when 'nchar' then 'String'
									when 'ntext' then 'String'
									when 'numeric' then 'decimal'
									when 'nvarchar' then 'String'
									when 'real' then 'double'
									when 'smalldatetime' then 'Date'
									when 'smallint' then 'short'
									when 'mediumint' then 'int'
									when 'smallmoney' then 'decimal'
									when 'text' then 'String'
									when 'time' then 'Date'
									when 'timestamp' then 'Date'
									when 'tinyint' then 'byte'
									when 'uniqueidentifier' then 'String'
									when 'varbinary' then 'byte[]'
									when 'varchar' then 'String'
									when 'year' THEN 'int'
									else 'UNKNOWN_' + DATA_TYPE
								end ColumnType,
                                COLUMN_NAME
			FROM
				(
					SELECT
						DATA_TYPE,
						COLUMN_TYPE,
                        COLUMN_NAME
					FROM
						INFORMATION_SCHEMA.COLUMNS
					WHERE
												table_name = vTabName
                                                order by ordinal_position
										) A
								) B
				);

		set		vClassGetSet= '';

		set		vClassPrivate= '';

		/* concat all properties*/
		OPEN code_cursor;

		get_code:
		LOOP
		FETCH code_cursor
		INTO v_codeChunk_pri_var,
				v_codeChunk_pub_get,
				v_codeChunk_pub_set;

		IF v_finished = 1 THEN LEAVE get_code;

		END
		IF;

				-- build code
				select
			CONCAT('\t', vClassPrivate, '\n', v_codeChunk_pri_var)
		into vClassPrivate;

		select
			CONCAT(
						'\t',
						vClassGetSet,
						'\n\t',
						v_codeChunk_pub_get,
						'\n\t',
						v_codeChunk_pub_set
					)
		into vClassGetSet;

		END LOOP get_code;

		CLOSE code_cursor;



create table
if not exists java_class as
select
    *
from
    temp1;

drop table temp1;

/* op file*/
SELECT REPLACE (
concat ('''C:\\\\mysql\\\\loadfiles\\\\ ',vClassName,'.java'''),' ','') INTO v_opfile;

/*make class*/
SET @v_sql = CONCAT ('SELECT ',
					'CONCAT(''package '',
				''',pPackageName,''','';'',
                ''\n@Entity\n@Table(name="'',
                ''',vTabName,''',
                ''")'',
				''\npublic class '',
				''',vClassName,''',
				''{\n'',
				''',vClassPrivate,''',
				''\n'',
				''\n}'') ',
                    'INTO OUTFILE ',
                    v_opfile);
/*SELECT @V_SQL;                    */
	

                
PREPARE dynamic_statement FROM @v_sql;
EXECUTE dynamic_statement;
DEALLOCATE PREPARE dynamic_statement;


END BLOCK2;
END LOOP get_tab;
CLOSE tab_cursor;
END BLOCK1;
END$$
DELIMITER ;
