CREATE OR REPLACE FUNCTION utf8clean(text) RETURNS TEXT AS $$
DECLARE
	string ALIAS FOR $1;
	i INT := 0;
	bytecount INT;
	bytes INT[];
	byte INT;
	tmp BYTEA := decode('5c', 'hex');  -- We just need some valid byte to use for set_byte src
	passed BYTEA;
  out TEXT;
BEGIN
	IF $1 is NULL OR octet_length($1) = 0
		THEN return $1;
	END IF;

	string := regexp_replace(string, '\\', '/', 'g');

	bytes := ARRAY(
		SELECT get_byte(string::bytea, x) FROM generate_series(0, octet_length(string) - 1, 1) x
	);

	IF array_length(bytes, 1) IS NULL
		THEN RETURN $1;
	END IF;

	bytecount := array_length(bytes, 1);

	-- Look forward implementation to avoid having to store seen values
	FOR i IN 0..bytecount LOOP
		byte := bytes[i];

		IF byte = 10 OR byte = 13 OR byte BETWEEN 32 AND 127 THEN -- 1-byte UTF8
			IF passed is NULL
				THEN passed := set_byte(tmp, 0, byte);
				ELSE passed := passed || set_byte(tmp, 0, byte);
			END IF;
		END IF;

		IF byte BETWEEN 194 AND 223 THEN -- 2-byte UTF8
			IF bytes[i+1] BETWEEN 128 AND 191 THEN
				IF passed is NULL
					THEN passed := set_byte(tmp, 0, byte);
					ELSE passed := passed || set_byte(tmp, 0, byte);
				END IF;

				passed := passed || set_byte(tmp, 0, bytes[i+1]);
			END IF;
			i := i + 1;
		END IF;

		IF byte = 224 THEN -- 3-byte UTF8
			IF bytes[i+1] BETWEEN 160 AND 191 AND bytes[i+2] BETWEEN 128 AND 191 THEN
				IF passed is NULL
					THEN passed := set_byte(tmp, 0, byte);
					ELSE passed := passed || set_byte(tmp, 0, byte);
				END IF;

				passed := passed || set_byte(tmp, 0, bytes[i+1]);
				passed := passed || set_byte(tmp, 0, bytes[i+2]);
			END IF;
			i := i + 2;
		END IF;

		IF byte BETWEEN 225 AND 236 THEN -- 3-byte UTF8
			IF bytes[i+1] BETWEEN 128 AND 191 AND bytes[i+2] BETWEEN 128 AND 191 THEN
				IF passed is NULL
					THEN passed := set_byte(tmp, 0, byte);
					ELSE passed := passed || set_byte(tmp, 0, byte);
				END IF;

				passed := passed || set_byte(tmp, 0, bytes[i+1]);
				passed := passed || set_byte(tmp, 0, bytes[i+2]);
			END IF;
			i := i + 2;
		END IF;

		IF byte = 237 THEN -- 3-byte UTF8
			IF bytes[i+1] BETWEEN 128 AND 159 AND bytes[i+2] BETWEEN 128 AND 191 THEN
				IF passed is NULL
					THEN passed := set_byte(tmp, 0, byte);
					ELSE passed := passed || set_byte(tmp, 0, byte);
				END IF;

				passed := passed || set_byte(tmp, 0, bytes[i+1]);
				passed := passed || set_byte(tmp, 0, bytes[i+2]);
			END IF;
			i := i + 2;
		END IF;

		IF byte BETWEEN 238 AND 239 THEN -- 3-byte UTF8
			IF bytes[i+1] BETWEEN 128 AND 191 AND bytes[i+2] BETWEEN 128 AND 191 THEN
				IF passed is NULL
					THEN passed := set_byte(tmp, 0, byte);
					ELSE passed := passed || set_byte(tmp, 0, byte);
				END IF;

				passed := passed || set_byte(tmp, 0, bytes[i+1]);
				passed := passed || set_byte(tmp, 0, bytes[i+2]);
			END IF;
			i := i + 2;
		END IF;

		IF byte = 240 THEN -- 4-byte UTF8
			IF bytes[i+1] BETWEEN 144 AND 191 AND bytes[i+2] BETWEEN 128 AND 191 AND bytes[i+3] BETWEEN 129 AND 191 THEN
				IF passed is NULL
					THEN passed := set_byte(tmp, 0, byte);
					ELSE passed := passed || set_byte(tmp, 0, byte);
				END IF;

				passed := passed || set_byte(tmp, 0, bytes[i+1]);
				passed := passed || set_byte(tmp, 0, bytes[i+2]);
				passed := passed || set_byte(tmp, 0, bytes[i+3]);
			END IF;
			i := i + 3;
		END IF;

		IF byte BETWEEN 241 AND 243 THEN -- 4-byte UTF8
			IF bytes[i+1] BETWEEN 128 AND 191 AND bytes[i+2] BETWEEN 128 AND 191 AND bytes[i+3] BETWEEN 129 AND 191 THEN
				IF passed is NULL
					THEN passed := set_byte(tmp, 0, byte);
					ELSE passed := passed || set_byte(tmp, 0, byte);
				END IF;

				passed := passed || set_byte(tmp, 0, bytes[i+1]);
				passed := passed || set_byte(tmp, 0, bytes[i+2]);
				passed := passed || set_byte(tmp, 0, bytes[i+3]);
			END IF;
			i := i + 3;
		END IF;

		IF byte = 244 THEN -- 4-byte UTF8
			IF bytes[i+1] BETWEEN 128 AND 143 AND bytes[i+2] BETWEEN 128 AND 191 AND bytes[i+3] BETWEEN 129 AND 191 THEN
				IF passed is NULL
					THEN passed := set_byte(tmp, 0, byte);
					ELSE passed := passed || set_byte(tmp, 0, byte);
				END IF;

				passed := passed || set_byte(tmp, 0, bytes[i+1]);
				passed := passed || set_byte(tmp, 0, bytes[i+2]);
				passed := passed || set_byte(tmp, 0, bytes[i+3]);
			END IF;
			i := i + 3;
		END IF;
	END LOOP;

	out := convert_from(passed, 'UTF8');

	RETURN out;
END;
$$ LANGUAGE plpgsql IMMUTABLE;