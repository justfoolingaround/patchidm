<h1 align="center">Internet Download Manager - Manual Windows Patch</h1>

With the script kiddies of the internet on the loose, it is no longer safe to trust any "crack" or "patch" as they might be riddled with credentials and cookie grabbers. So, any normal user can do two of the following to use a premium software without any risk:
    
- Purchase a license, or
- Patch the license manually.

I'm basically going to be guiding you to do the latter option.

## Permanent* Patch

### Step 1: Download the registry

We're going to be using [this registry](https://raw.githubusercontent.com/J2TEAM/idm-trial-reset/8d85c475094c5b941ab917e2b6e5732e72076f1c/src/idm_reg.reg).

You can either download it via your browser, copy the contents to a text file and save it with the `.reg` extension **or** just run the following cURL command.

```sh
curl -s "https://raw.githubusercontent.com/J2TEAM/idm-trial-reset/8d85c475094c5b941ab917e2b6e5732e72076f1c/src/idm_reg.reg" -o "idm_reg.reg"
```

Then, what you would want to do would be to edit the file yourself and change the lines 4 to 6 to your own values. I would set that to:

```
"FName"="justfoolingaround"
"LName"="(KR)"
"Email"="kr.justfoolingaround@gmail.com"
```

Then after, run the registry file. 

It is preferred to first backup the registry files, though there is no real risk here unless you edit the registry too carelessly to add some weird values.

### Step 2: Edit the `hosts` file

This is **very** necessary if you want to rid yourself of the "counterfeit serial key" issue.

You just need to open the `hosts` file with a text editor with administrator privileges.

Simply follow these steps:

- Hit <kbd>WIN + X</kbd> followed by <kbd>A</kbd>, this will prompt you to open your terminal with administrator privileges.
- Run the following command:

    If you're in cmd,

    ```cmd
    notepad %windir%/System32/drivers/etc/hosts
    ```

    If you're in powershell,

    ```pwsh
    notepad ${env:windir}/System32/drivers/etc/hosts
    ```

After opening your text editor, just add the following lines:

```
127.0.0.1           registeridm.com
127.0.0.1           www.registeridm.com
127.0.0.1           secure.registeridm.com
127.0.0.1           www.internetdownloadmanager.com
127.0.0.1           secure.internetdownloadmanager.com
127.0.0.1           mirror.internetdownloadmanager.com
127.0.0.1           mirror2.internetdownloadmanager.com
127.0.0.1           mirror3.internetdownloadmanager.com
```

Save the file. Then after, you will need to set your hosts file as read-only to ensure that IDM doesn't tamper with it on its start-up.

You can do this by going to the properties of the host file or with the following command:

If you're in cmd,

```cmd
attrib +r %windir%/System32/drivers/etc/hosts
```

If you're in powershell,

```pwsh
attrib +r ${env:windir}/System32/drivers/etc/hosts
```

Now, you can just restart IDM and it should be good to go.

For automatic patching, run the following command in PowerShell. Please be sure to review the contents of the [target script](./scripts/permanent_patch.ps1).

```pwsh
Invoke-Expression "& { $(Invoke-WebRequest -UseBasicParsing 'https://github.com/justfoolingaround/patchidm/raw/master/scripts/permanent_patch.ps1') }"
```
