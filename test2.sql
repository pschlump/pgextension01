
-- A tests that results in 'pass'/'fail' 

DO $$
DECLARE
 	l_txt text;
 	n_err int;
	l_msg text;
BEGIN

 	n_err = 0;

	SELECT convert_to_title('12345')
		into l_txt;
	if l_txt != '12345' then
		RAISE NOTICE 'Failed to convert 12345 to 12345';
		n_err = n_err + 1;
	end if;

	SELECT convert_to_title('A Title')
		into l_txt;
	if l_txt != 'A Title' then
		RAISE NOTICE 'Failed to convert "A Title" to "A Title"';
		n_err = n_err + 1;
	end if;

	SELECT convert_to_title('a title')
		into l_txt;
	if l_txt != 'A Title' then
		RAISE NOTICE 'Failed to convert "a title" to "A Title"';
		n_err = n_err + 1;
	end if;


	if n_err = 0 then
		RAISE NOTICE 'PASS';
	else 
		RAISE NOTICE 'FAIL';
	end if;

END;
$$ LANGUAGE plpgsql;

