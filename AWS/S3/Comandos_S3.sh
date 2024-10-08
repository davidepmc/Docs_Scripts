export AWS_ACCESS_KEY_ID=xxxxxxx
export AWS_SECRET_ACCESS_KEY=yyyyyy
export AWS_CA_BUNDLE=/etc/pki/tls/cert.pem
export AWS_DEFAULT_OUTPUT=json
export AWS_DEFAULT_REGION=es-tc-1
export S3_ENDPOINT=zzzzzzz

aws s3 ls --human-readable  --endpoint-url $S3_ENDPOINT s3://besbckporacdbwork-l/es-work/tst/c10esdev/c10esdev_tca/655706915/export/

LS de los ficheros de un bucket

	aws s3api list-objects --bucket besbckporacdbwork-l --endpoint-url $S3_ENDPOINT

LS de las versiones de un fichero

	aws s3api list-object-versions --bucket besbckporacdbwork-l --endpoint-url $S3_ENDPOINT | grep -b3a6 file_name

	aws s3api list-object-versions --bucket besbckporacdbwork-l --endpoint-url $S3_ENDPOINT | grep -b3a6 file_name

DELETE de un fichero y una version en concreto

	aws s3api delete-object --bucket besbckporacdbwork-l --endpoint-url $S3_ENDPOINT --key file_name --version-id 3938323731363330333436333235393939393939524754433031203539322e3630303631333139302e31313436343432

RESTORE de un fichero

	aws s3api get-object --bucket besbckporacdbwork-l --endpoint-url $S3_ENDPOINT --key es-work/tst/c10esdev/c10esdev_tca/655706915/export/export_full_no_data.log export_full_no_data_current.log

RESTORE de la version de un fichero.

	aws s3api get-object --bucket besbckporacdbwork-l --endpoint-url $S3_ENDPOINT --key es-work/tst/c10esdev/c10esdev_tca/655706915/export/export_full_no_data.log --version-id 3938323731363039333530323839393939393939524754433031203539322e3630303830373631372e31313632383639 export_full_no_data_current_ver_39.log 