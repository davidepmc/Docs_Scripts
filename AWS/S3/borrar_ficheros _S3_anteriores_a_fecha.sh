export AWS_ACCESS_KEY_ID=YM8DG7IBL4PLHKE8LTKP
export AWS_SECRET_ACCESS_KEY=jpIE0yKPwKJy5qsv6S0o3SpBZGuR2ZPp74MPrkqd
export AWS_CA_BUNDLE=/etc/pki/tls/cert.pem
export AWS_DEFAULT_OUTPUT=json 
export AWS_DEFAULT_REGION=es-tc-1
export S3_ENDPOINT=https://s3backup.es.nextgen.igrupobbva:8443
alias aws=/home/postgres/.local/lib/aws/bin/aws
export accname=AesPstLIVE
export accquota=375809638400
export bytetotb=1073741824

#Ver el tamanio ocupado en un bucket

	bucket=`/home/postgres/.local/lib/aws/bin/aws s3api list-buckets --endpoint-url $S3_ENDPOINT --query "Buckets[].Name"`
	
	
	#Clean2 name buckets
	bucketcl=`echo "$bucket" | sed 's/\"//' | awk '{print substr ($ 0, 2, length ($ 0) - 2)}' | sed 's/\"//'`
	
	for  i in $bucketcl 
	
	do 
	size=`/home/postgres/.local/lib/aws/bin/aws s3api list-object-versions --endpoint-url $S3_ENDPOINT --bucket $i --output json --query "sum(Versions[].Size)"`
	 for  j in $size 
	 do 
	 echo "oracle_bbdd_os_s3_occupation,product=oracvir,name=$i size=$((size / bytetotb ))"
	 done
	done 
	
	echo "oracle_bbdd_os_s3_occupation,product=oracvir,name=$accname size=$((accquota / bytetotb))"




#borrar ficheros anteriores a una fecha



    export AWS_CA_BUNDLE=/etc/pki/tls/cert.pem
    export AWS_ACCESS_KEY_ID=YM8DG7IBL4PLHKE8LTKP 
    export AWS_SECRET_ACCESS_KEY=jpIE0yKPwKJy5qsv6S0o3SpBZGuR2ZPp74MPrkqd
    export AWS_DEFAULT_OUTPUT=json 
    export AWS_DEFAULT_REGION=es-tc-1
    export S3_ENDPOINT=https://s3backup.es.nextgen.igrupobbva:8443
    rmDate=`date -d "16 day ago" +%F`
    filestodelete=`/home/postgres/bin/aws s3 ls --recursive s3://besbckppglive/es-live/pro/eslcp01 --endpoint-url $S3_ENDPOINT | awk '$1 < "'${rmDate}' 00:00:00" {print $4}'`


    for i in $filestodelete 

    do

    /home/postgres/bin/aws s3 rm s3://besbckppglive/$i --endpoint-url $S3_ENDPOINT

    done