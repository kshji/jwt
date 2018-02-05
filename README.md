# JWT Shell Script Encode and Decode JWT Token #

  * [Jwt doc](https://jwt.io/)
  * [Jwt libs](https://jwt.io/)
  * [Jwt debug](https://jwt.io/)


JWT Token encode and decode libraries for Token Signing/Verification have listed
on [Jwt.io](https://jwt.io/) site, but not for shell scripts.

I have put examples to my **jwt.sh** script to handle JWT in any Posix compatible shells (ksh, bash, dash, zsh, ...)

You need openssl to run this scripts. 

Also [Jq](https://stedolan.github.io/jq/) command-line JSON processor helps to parse JSON elements.
[Ksh93](https://github.com/att/ast) include builtin json element support, but other shell not. I used jq to 
make generic solution.


Syntax :

        jwt.sh [options] -e |  -d  -j jwt_access_token
                -e # encode
                -d token # decode
                -t sec          # timetolive token
                -s secretkey
                --debug 0|1

Example encode:

                jwt.sh --debug 1 -e -s "somesec"

                jwt.sh -e -s "somesec" -t 1

Example decode:

                jwt.sh --debug 1 -d -s "somesec" -j "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEiLCJpc3MiOiJTaCBKV1QgR2VuZXJhdG9yIiwiZXhwIjoiMTUxNzc2NDcxNyIsImlhdCI6IjE1MTc3NjExMTcifQ.eyJJZCI6MSwiTmFtZSI6Ik15IE5hbWUifQ.Yjiif1mZfHV0V49NLE2e0LI5GY6wJ9LLk0pH1Y0"

                jwt.sh -d -s "somesec" -j "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImtpZCI6IjAwMDEiLCJpc3MiOiJTaCBKV1QgR2VuZXJhdG9yIiwiZXhwIjoiMTUxNzc2NDcxNyIsImlhdCI6IjE1MTc3NjExMTcifQ.eyJJZCI6MSwiTmFtZSI6Ik15IE5hbWUifQ.Yjiif1mZfHV0V49NLE2e0LI5GY6wJ9LLk0pH1Y0"


