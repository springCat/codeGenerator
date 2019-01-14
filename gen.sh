#! /bin/bash

TABLE_NAME=$1
PACKAGE=$2
FILE_PATH=$3

DBNAME=test
DB_USERNAME=root

#fetch table info from mysql
eval "mysql -u$DB_USERNAME -D test <<EOF
select t.COLUMN_NAME,t.DATA_TYPE,t.NUMERIC_PRECISION,t.COLUMN_COMMENT from information_schema.columns t where t.TABLE_NAME=\"$TABLE_NAME\" and t.TABLE_SCHEMA=\"$DBNAME\" order by t.ORDINAL_POSITION;
EOF" | in2csv --format csv > ./$TABLE_NAME.csv

#build jdbc type transform
eval "cat<<EOF
DATA_TYPE,JDBC_TYPE
bigint,Long
tinyint,Byte
smallint,Short
mediumint,Integer
integer,Integer
int,Integer
float,Float
double,Double
decimal,BigDecimal
numeric,BigDecimal
char,String
varchar,String
tinyblob,DataTypeWithBLOBs.byte[]
tinytext,String
blob,DataTypeWithBLOBs.byte[]
text,DataTypeWithBLOBs.String
mediumblob,DataTypeWithBLOBs.byte[]
mediumtext,DataTypeWithBLOBs.String
longblob,DataTypeWithBLOBs.byte[]
longtext,DataTypeWithBLOBs.String
date,Date
time,Date
year,Date
datetime,Date
timestamp,Date
EOF
" > jdbc.csv

#covert dbtype to java type
csvjoin -c DATA_TYPE $TABLE_NAME.csv jdbc.csv > gen.csv

CLASS_NAME=`echo $TABLE_NAME | sed -r 's/t_//g'`
CLASS_NAME=`echo $CLASS_NAME | sed -r 's/(^|_)([a-z])/\U\2/g'`
JAVA_FILE_PATH=${FILE_PATH}/${CLASS_NAME}.java

#clean java
if [[ -f ${JAVA_FILE_PATH} ]]; then
	rm ${JAVA_FILE_PATH}
fi

#class start
eval "cat <<EOF
package ${PACKAGE};
/**
* table_name:${TABLE_NAME}
* @author springcat
*/
import java.util.Date;
public class ${CLASS_NAME}
{
EOF" >> ${JAVA_FILE_PATH}

#column
sed -i '1d' gen.csv

while read line
do
	cmd=`echo $line | awk -F "," '{print "COLUMN_NAME="$1,"COLUMN_COMMENT="$4,"JDBC_TYPE="$5}'`;
	eval $cmd
	JAVA_COLUMN_NAME=`echo $COLUMN_NAME | sed -r 's/(_)([a-z])/\U\2/g'`
	eval "cat<<EOF

	    /**
	     * ${COLUMN_COMMENT}
	     */
	    private ${JDBC_TYPE} ${JAVA_COLUMN_NAME};
	EOF
	" >> ${JAVA_FILE_PATH}
done < gen.csv

#class end
echo "}" >> ${JAVA_FILE_PATH}

#clean
rm jdbc.csv
rm gen.csv
rm $TABLE_NAME.csv

echo "gen java bean ${JAVA_FILE_PATH}  success"

