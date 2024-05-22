#/ /bin/bash

set -ex

isValidMailID() {
    local email=$1
    local regex='^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    if [[ $email =~ $regex ]]; then
        echo "Enter Email ID is Valid: $email"
        return 0
    else
        echo "Enter Email ID is Invalid: $email"
        return 1
    fi
}


if [ $# -eq 0 ]; then
    echo "Usage: $0 email ID"
    exit 1
fi

if [[ -z "$1" ]]; then  
    echo "First Arguement has to be E-Mail ID"
    exit 1
else
   isValidMailID "$1"
   if [ $? -eq 0 ]; then
        echo "Email ID is valid"
   else
        echo "Invalid EMAIL ID format"
        exit 1
   fi
fi
if [[ -z "$2" ]]; then  
    echo "Using Default filename"
    filename="id_rsa"
else
    echo "Using Custom filename $2"
    filename=$2
fi
home_path=$(eval echo ~$USER)
private_key_file="$home_path/.ssh/$filename"
public_key_file="$home_path/.ssh/$filename.pub"
# Check if the private key file exists
#Generate SSH key
echo $private_key_file
if [ -e $private_key_file ]; then
    rm -f $private_key_file
fi

if [ -e $public_key_file ]; then
    rm -f $public_key_file
fi

ssh-keygen -q -t rsa -b 4096 -C $1 -f ~/.ssh/$filename -N ""