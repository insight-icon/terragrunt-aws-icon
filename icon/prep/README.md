
# ICON P-Rep Configurations 

We are continuously evolving our P-Rep deployment as the protocols mature.  Currently we are in phase 1 of the network where only one IP address is allowed to be whitelisted which prevents us from putting the P-Rep in a private subnet / using a load balancer in front of it with a sentry layer. Work was started on this  and hence there are multiple different node deployments in active development. They are:

### Phase 1
**One to One Deployments**  - Old Style 
- `prep-basic`
	- A 1 to 1 module approach that deploys to a custom VPC 
- `prep-citizen`
	- Same as the basic with a citizen node to sync off of.  
- `prep-ha`
    - WIP
	- HA setup with two nodes in a Active / Passive pattern deployed with Pacemaker 

**All in One Module Deployments** - Current Style 
- `prep-module`
	- A single module deployment that is capable of being run directly from terraform with out terragrunt
	- Deploys into default VPC 
- `prep-module-vpc`
	- Same as `prep-module` but deploys into created VPC 
	
## Phase 2 / 3
- `prep-ha-sentry`
	- Only the sentry layer for the P-Rep. Same as prep-ha but with a sentry layer in front of it 


