DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `camelCase`(str varchar(128)) RETURNS varchar(128) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE n, pos INT DEFAULT 1;
DECLARE sub, proper VARCHAR(128) DEFAULT '';

if length(trim(str)) > 0 then
    WHILE pos > 0 DO
        set pos = locate('_',trim(str),n);
        if pos = 0 then
            set sub = lower(trim(substr(trim(str),n)));
        else
            set sub = lower(trim(substr(trim(str),n,pos-n)));
        end if;

        set proper = concat_ws('', proper, concat(upper(left(sub,1)),substr(sub,2)));
        set n = pos + 1;
    END WHILE;
end if;

SET proper= trim(proper);
SET proper = CONCAT(
											LCASE(MID(proper, 1, 1)),
											MID(proper, 2)								) ;
RETURN proper;
END$$
DELIMITER ;
