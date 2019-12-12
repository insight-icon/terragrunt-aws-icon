# terraform-aws-icon-preptools-s3

This module helps with registering a node on the ICON Blockchain. It does three main things. 

- Creates an elastic IP that will be your main IP that your node will use to run 
- Puts the necessary details.json file in a bucket publicly accessible 
- Outputs the commands you need to run in preptools 

Future versions will run preptools automatically and will be idempotent (ie can run as many times as you want without breaking things). 

## Using this module 

Fill out the appropriate values in `terragrunt.hcl`. Few notes, 

```hcl
// This MUST be set right from the get go. Options are `mainnet` or `testnet` 
//  If you do this wrong for main, you will have to switch wallet most likely (untested)
network_name = "testnet"

// If you leave these commented out, you will be prompted for password each time
// If you run this module directly, (terragrunt apply), fill it out like this to prevent password from hitting disk 
  keystore_password = ""
//keystore_password = local.secrets["keystore_password"]
``` 

You never want to destroy the IP that you use to register so feel free to modify the lines below. 

**From** 
```hcl
  lifecycle {
    prevent_destroy = false
  }
```

**To** 
```hcl
  lifecycle {
    prevent_destroy = true 
  }
```

EIPs are not covered under the free plan and cost money when they are not in use.  To destroy the EIP after you set the `prevent_destroy` protection, you have to reapply the module with the `prevent_destroy` set to false. 

#### Running the module 
To run the module run this within this directory:

```bash
terragrunt apply
```

#### Registering the node 
The output of the module will contain lines similar to this. 

**Test Net**
```bash
preptools registerPRep \
> --url https://zicon.net.solidwallet.io \
> --nid 2 \
> --keystore /c/Users/rob/PycharmProjects/blockchain/icon/registration/InsightTN4C4/keystore \
> --name "Insight-C2" \
> --country "USA" \
> --city "San Francisco" \
> --email "insight.icon.prep@gmail.com" \
> --website "insight-icon.net" \
> --details http://prep-registration-upright-molly.s3-website-us-east-1.amazonaws.com/details.json \
> --p2p-endpoint "3.229.229.89:7100"
```

Copy and paste these lines into your terminal to register your node. 

## TTD 

- Have preptools register automatically within the module 
	- There is an error with the registration process 
- Put an object in S3 that qualifies whether `preptools registerPRep` has run already in which case all future commands are `preprools setPRep` to update documents. 
