Security groups for deployment.  Relies on a `global.yaml` file at the root of the repo to determine which security groups to enable so that you don't have extraneous rules that are not needed being added to your deployment. Your `global.yaml` file will look something like this: 

```yaml
vault_enabled: true
bastion_enabled: false
monitoring_enabled: false
hids_enabled: true
logging_enabled: true
consul_enabled: true
```

Because of circular dependencies, two security groups have their rules applied separately.  They are `sg-consul-rules` and `sg-bastion-rules`.  These are applied off a fork of the official `terraform-aws-modules/terraform-aws-security-group` module to only apply rules instead of creating an additional security group.  This allows us to have a 1 to 1 mapping of security groups with their associated instances. 

All security groups are tagged based on the label module in the parent dir so their state can be referenced either through a data source based on filter of tags , name, 

See source for details on ports. 

### TTD 

- Check vault rules 
- Restrict consul to security groups instead of cidr blocks 
- Check exporters for monitoring 
