# terragrunt-aws-icon

**Work in progress** - Please get in touch 

This is the second iteration of an automated deployment for running nodes and supporting infrastructure on the ICON Blockchain. 

### To Use 
---
1. ##### Export AWS keys to environment variables or profile 
	- Visit [this link](https://www.notion.so/insightbxplanning/AWS-Keys-Tutorial-175fa12e9b5b43509235a97fca275653) for more information 
2. ##### Install prerequisites 
	- [Check this section](#prerequisites)
	- `make install-deps-ubuntu` or `make install-deps-mac` 
3. ##### Pull in dependencies 
    - `make clone-all`
4. ##### Make sure you have ssh keys
	- `ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f $HOME/.ssh/icon_node`
	- Take note of the path that you create the keys in as you will need it in the next section

5. #####  Fill in the necessary inputs in config files at base of directory 
    - You have numerous options to fill out the config files needed to run a deployment.
    - All options require that you have the paths to your ssh keys and keystore
    - Option #1 and #2 both overwrite your configs each time you do it 
    - **Option #1** - Get prompted to fill in values 
        - Run `make configs-prompt`
    - **Option #2** - Fillout higher level config (best method)
        - Change `config.yaml.examle` to `config.yaml` and fill out choices 
        - Run `make configs-from-config`
    - **Options #3** - Fill out lower level configs manually 
        - There are five files generated from above options. Create them per above then edit manually. 
            - `global.yaml`
                - Information about network and general setup  
            - `secrets.yaml`
                - Secret values like the keystore password (yeah, we know...) and paths to ssh keys / keystore 
            - `account.tfvars`
                - Your AWS account number
            - `region.tfvars`
                - The region you deploy into.  Same as in global.yaml
            - `node.yaml`
                - The specs for your node. 
	> ##### Make sure you choose the right network!
6. ##### Register node
	- You will need to regster the node.  Check the official docs 
	- Fill out the config file `registration.yaml` appropriately 
	- `make eip-register` 
	- Copy the output "registration command" and run in shell. Command begins with preptools...
	- This is a one time process for most people 
	
7. ##### Deploy node
	- We have several variations of the node deployment in various stages of development.  
	- Most stable version right now is the prep-module or prep-basic 
	- Developers will want to know how to deploy all the pieces individually 
	- To deploy the most basic version, run:

```
make apply-prep-module
```

To turn off your node, run:
```bash
make destroy-prep-module
```

To deploy advanced features, you will need to run a different set of commands to deploy a custom VPC as well. 

```bash
make apply-network 
make apply-prep-module-vpc 
make apply-<feature under development> 
```
And to destroy:
```bash
make destroy-network 
make destroy-prep-module-vpc 
make destroy-<feature under development> 
```

### Areas of Development 
---
To view a complete list of areas that we are working on, check [this link](https://www.notion.so/insightbxplanning/ec755b12bffa4cfca2026b76f035b096?v=bc2712a04ccb468f9847f0cc5a4912cd). 

Short list being: 
- Improved monitoring and alerting 
- DDoS protection using Envoy 
- Host intrusion detection systems
- Vault secrets management 
- Improved deployment and testing patterns 

Get in touch with Rob if you want to help / need a walk through of the repo. 

### Prerequisites
---
The deployment works on both Linux and Mac. For windows you will want to install Ubuntu WSL.  
- To install dependencies, first try the Makefile
    - Mac - Have brew installed then `make install-deps-mac` from the root of repo 
    - Ubuntu - `make install-deps-ubuntu`
- Visit [this link](https://www.notion.so/insightbxplanning/Installing-Prerequisites-0def287ace304b4b98326b743f88d30b) for more information 
- Here are most of the programs - may be some dependencies of these missing, hence check link above. 
	- nodejs 
	- [meta](https://github.com/mateodelnorte/meta)
	- terraform
	- terragrunt 
	- packer 
	- ansible 
	- build-essential 
	- awscli 
	- pip 
		- requests==2.20.0
		- preptools 

### Further Reading 

- [Developer-Tutorials](https://www.notion.so/insightbxplanning/Developer-Tutorials-bd090555d1a841b48e34d3b675c58f94)
- [Introductory-Tutorials](https://www.notion.so/insightbxplanning/Introductory-Tutorials-0416f96a30ee485f9e30c3a75b4910bf)
- [Operator-Tutorials](https://www.notion.so/insightbxplanning/Operator-Tutorials-bc2b8b1d0f344b6cab3da2cb193eb3ab)
- [Technology-Directory](https://www.notion.so/insightbxplanning/Technology-Directory-acc71617035743ae858c0699e4de4bab)
