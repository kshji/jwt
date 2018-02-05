#!/bin/ksh
# jwt.sh
# compatible shells: bash / ksh / dash /zsh
# Jukka Inkeri
# 2018-02-04
#
# https://jwt.io/ other language libraries and debug
# JWT Debugger  is good place to check
# ...

PRG="$0"
defsecret='SomeSecretKey'
debug=0
epoc=$(date +%s)  # epoc timestamp
timetolive=3600   # token timetolive seconds

#####################################################################
# templates
#
payload='{
"Id":1,
"Name":"My Name"
}'

header=""

#####################################################################
make_header()
{
cat <<-EOF
  {
  "typ":"JWT",
  "alg":"HS256",
  "kid":"0001",
  "iss":"Sh JWT Generator",
  "exp":"$(( epoc + timetolive  ))",
  "iat":"$epoc"
  }
EOF
}


#####################################################################
dbg()
{
	((debug<1)) && return
	echo "$*" >&2
}

#####################################################################
verify_signature()
{
	
	header_payload="$1"
	signature="$2"
	seckey="$3"
	dbg "verify_signature" 
	dbg "-header_payload:$header_payload" 
	dbg "-signature:$signature" 
	dbg "-seckey:$seckey" 

	expected=$(printf "%s" "$header_payload" | openssl dgst -binary -sha256 -hmac "$seckey")
  	expected_base64=$(printf "%s" "${expected}" | openssl base64 -e | tr '+/' '-_' | tr -d '=\n')

	[ "$expected_base64" = "$signature" ] && return 0
	echo "Signature is NOT valid" >&2
	dbg "sig|exp: $signature |  $expected_base64 " 
	return 1
}


#####################################################################
decode_jwt()
# - decode token
{
	jwtstr="$1" 
	secret="$2"
	[ "$jwtstr" = "" ] && usage && exit 2
	[ "$secret" = "" ] && secret="$defsecret"  # - use default

	dbg "decode_jwt"
	dbg "-jwtstr:$jwtstr"
	# split to array flds using . delimiter
	IFS="." flds=($jwtstr)
	header=${flds[0]}
	payload=${flds[1]}
	signature=${flds[2]}

	dbg "-header:$header" 
	dbg "-payload:$payload" 
	dbg "-signature:$signature" 
	dbg "-secret:$secret" 

	headertxt=$(printf '%s' "${header}==" | openssl enc -base64 -d -A)
	dbg " - Header:$headertxt"

	payloadtxt=$(printf '%s' "${payload}==" | openssl enc -base64 -d -A)
	dbg " - Payload:$payloadtxt"
	
	verify_signature "${header}.${payload}" "$signature" "$secret" || exit 10 # signature error

	exp=$(echo "$headertxt" | jq .exp)
	((exp < epoc )) && echo "Expired token" >&2 && exit 11

	echo "header $headertxt" 
	echo "payload $payloadtxt" 

}

#####################################################################
make_jwt()
# - encode
{
	# setup secret key
	secret="$1" 
	[ "$secret" = "" ] && secret="$defsecret"  # - use default
	dbg "make_jwt" 
	dbg "-secret:$secret" 
	header=$(make_header)
	
	#########################
	# command 
	#   base64 
	# is same as 
	#   openssl base64 -e
	header_base64=$(printf "%s" "$header" | tr -d '\n' | openssl base64 -e | tr '+/' '-_' | tr -d '=\n')
	payload_base64=$(printf "%s" "$payload" | tr -d '\n' | openssl base64 -e | tr '+/' '-_' | tr -d '=\n')
	signature=$(printf "%s" "${header_base64}.${payload_base64}" | openssl dgst -binary -sha256 -hmac "$secret" )
	signature_base64=$(printf "%s" "${signature}" | openssl base64 -e | tr '+/' '-_' | tr -d '=\n')
	dbg "-header:$header_base64"
	dbg "-payload:$payload_base64"
	dbg "-signature:$signature_base64"
	echo "${header_base64}.${payload_base64}.${signature_base64}"
}

#####################################################################
usage()
{
	echo "usage:$PRG [options] -e |  -d  -j jwt_access_token  
		-e # encode
		-d token # decode
		-t sec   	# timetolive token
		-s secretkey
		--debug 0|1
	
	Example:
		Encode
		jwt.sh --debug 1 -e -s "somesec"
		jwt.sh -e -s "somesec" -t 1

		Decode
		jwt.sh --debug 1 -d -s "somesec" -j "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEiLCJpc3MiOiJTaCBKV1QgR2VuZXJhdG9yIiwiZXhwIjoiMTUxNzc2NDcxNyIsImlhdCI6IjE1MTc3NjExMTcifQ.eyJJZCI6MSwiTmFtZSI6Ik15IE5hbWUifQ.Yjiif1mZfHV0V49NLE2e0LI5GY6wJ9LLk0pH1Y0"
		jwt.sh -d -s "somesec" -j "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEiLCJpc3MiOiJTaCBKV1QgR2VuZXJhdG9yIiwiZXhwIjoiMTUxNzc2NDcxNyIsImlhdCI6IjE1MTc3NjExMTcifQ.eyJJZCI6MSwiTmFtZSI6Ik15IE5hbWUifQ.Yjiif1mZfHV0V49NLE2e0LI5GY6wJ9LLk0pH1Y0"

	" >&2
}


#####################################################################
# MAIN
#####################################################################

prg=""
while [ $# -gt 0 ]
do
	arg="$1"
	case "$arg" in
		-t) timetolive="$2" 		; shift ;;
		-s) secret="$2" 		; shift ;;
		-e) prg="encode"  			;;
		-d) prg="decode"			;; 
		-j) token="$2"			; shift ;;
		--debug) debug="$2" 		; shift ;;
	esac
	shift
done

case "$prg" in
	encode)  make_jwt "$secret"  ;;
	decode)  decode_jwt "$token" "$secret" ;;
	*) usage ; exit 1 ;;
esac
