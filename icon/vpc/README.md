Data ref here as this resource does not want to get caught in the wrong graph. Queries based on namespace, environment, network_name (mainnet vs testnet), and vpc_type (main, monitoring, etc...). 

Gets this information from `global.yaml` at the root but could be changed to the label module and iterate through tags for vpc data ref. 

Returns the basic vpc information that you need per the format of the official VPC module outputs. 
