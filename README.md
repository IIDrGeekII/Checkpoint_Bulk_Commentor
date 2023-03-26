## Checkpoint_Bulk_Commentor

This program is a shell script written in Bash, a Unix shell that runs in a command-line interface (CLI). The program aims to automate the task of checking and printing bulk comment on all the non-commented rules within a Check Point firewall using API. 

This script is tested on R80+ and R81+ series GAIA OS.

![image](https://user-images.githubusercontent.com/75925433/226100976-88b7d5ba-390d-4d44-b504-d4044c2987e5.png)

In this the user is prompted to enter the IP address or name of the domain or SMS (Security Management Server) they want to check.

Once the user enters the domain name or IP address, the script uses the Checkpoint API command-line interface tool "mgmt_cli" to show a list of available policy package names for that domain. The user is prompted to enter the name of the policy package they want to check.

The script then determines the size of the rulebase of the specified policy package using the "show access-rulebase" command with the "total" option. Once that is fetch it will display the total number of rules that are present on that policy package.

![image](https://user-images.githubusercontent.com/75925433/226101180-4b828e36-9282-47f3-97a0-62b8c991f401.png)

> **Note:**
    *Keep in mind that sometimes we use custom name for policy package and if that is the case then after extracting available policy packages it will display name such as below,*

```
Listing all available Policy Package Names...

customname1 Network
customname2 Network
customname3 application
```
> *In such case while specifying policy package name, specify complete name like : customname1 Network*

Once all the available rules from the selected policy packages are displayed it then asks to scan total rules. This is required as it sets the limit to the mentioned number

> *by-default Checkpoint firewall only scan first 50 rules. That's why mentioning "number of rules to scan" is must.*

![image](https://user-images.githubusercontent.com/75925433/226101270-63da1531-8d9a-440e-9d23-9ea2fedf84ca.png)

Once the scan is completed, it show total number of rules that are currently not having any comment.

The user is then prompted to select one of the following options:

```
    1. Comment Rules
    2. Check for different policy package
    3. Quit Program
```
Based on the user's selection, the script then move further accordingly.

On selecting 1st option, it asks for credentials of "Smartconsole" to create a session and then ask for the comment that you want to print on the rules.

After providing the comment it then executes the "mgmt_cli" API command to print comments on all the rules that are not commented.

![image](https://user-images.githubusercontent.com/75925433/226101997-d4147d62-d608-4f02-ac9c-0b2e1c74c3d1.png)

he user is then prompted to select one of the following options:

```
    1. Publish
    2. Discard
    3. Check for different policy package
    4. Quit Program
```

Once all the rules are commented, it then asks whether to publish the changes or to discard it or whether to comment more rules from different policy package. 

![image](https://user-images.githubusercontent.com/75925433/226102292-5f710ec1-690b-4bc7-9e9e-eeb4fd4de24c.png)

The script uses the "jq" command-line tool to parse the JSON output of the **"mgmt_cli"** command and extract the relevant information.

To execute this program, follow these steps:

    1. Open a terminal of Checkpoint Management Server.
    
    2. Save the program to a file with a ".sh" extension.
    
    3. Set the file's permissions to allow execution by running the command "chmod +x cpcommnetor.sh".
    
    4. Run the program by entering "./cpcommentor.sh" in the terminal
    
    5. Follow the prompts and enter any required inputs.
    
    7. The program will execute the selected function and display the results.


