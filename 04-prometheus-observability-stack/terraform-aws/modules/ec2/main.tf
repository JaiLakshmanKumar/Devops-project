resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  count         = var.instance_count

  /*
  Concept	        Meaning
user_data	        startup script (text)
runs when	        instance first boots
update            effect	forces restart (stop/start)
user_data_base64	used for encoded scripts

since im encoding this as my file is large using user_data_base64
  */
  user_data_base64 = base64encode(file("${path.module}/user-data.sh")) 

  root_block_device {
    volume_size = var.volume-size  # Size in GB
    volume_type = "gp2"  # EBS volume type
  }
  
  vpc_security_group_ids = var.security_group_ids


//element function picks up one element from the list using the number mentioned in second arg
//if count  = 3 then count.index iterates 0, 1, 2. 
//since count is not defined in below case then count = 0

//next approach is for_each.
  subnet_id = element(var.subnet_ids, count.index % length(var.subnet_ids))


//merge function 
/*
If more than one given map or object defines the same key or attribute, then the one that is later in the argument sequence takes precedence
*/
  tags = merge(
    {
      Name        = "${var.environment}-${var.application}"
      Environment = var.environment
      Owner       = var.owner
      CostCenter  = var.cost_center
      Application = var.application
    },
    var.tags
  )
}
