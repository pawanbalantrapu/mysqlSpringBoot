DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenJavaDAOAllTabs`(
    in pPackageName varchar
(255),
    in pSchemaName VARCHAR
(255)
)
BEGIN


BLOCK1: BEGIN
DECLARE vTabName varchar    (255);
DECLARE vClassName varchar    (255);
DECLARE vClassNameDao varchar    (255);
DECLARE v_opfile varchar    (255);
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
		
SELECT proper_case(vTabName) INTO vClassName;

SELECT CONCAT (vClassName,'Dao') INTO vClassNameDao;


/* op file*/
SELECT REPLACE (
concat ('''C:\\\\mysql\\\\loadfiles\\\\ ',vClassNameDao,'.java'''),' ','') INTO v_opfile;

/*make class*/
SET @v_sql = CONCAT ('SELECT ',
					'CONCAT(''package '',
				''',pPackageName,''','';'',
                ''\nimport org.springframework.data.jpa.repository.JpaRepository;\n'',
				''\npublic interface '',
				''',vClassNameDao,''',
                ''  extends JpaRepository<'',
                ''',vClassName,''',
                '', Long>''
				''{\n'',
				''\n}'') ',
                    'INTO OUTFILE ',
                    v_opfile);
/*SELECT @V_SQL;                    */
	

                
PREPARE dynamic_statement FROM @v_sql;
EXECUTE dynamic_statement;
DEALLOCATE PREPARE dynamic_statement;

END LOOP get_tab;
CLOSE tab_cursor;
END BLOCK1;
END$$
DELIMITER ;
