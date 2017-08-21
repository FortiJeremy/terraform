import boto3
from boto3.session import Session
region = ‘region’
rts = { ‘route_table_1’, ‘route_table_2’ }
def get_healthy_rt (troubled_rt_id):
 for rt_id in rts:
   if rt_id != troubled_rt_id:
     return rt_id
 
 
def do (event, context):
  
 session = Session(region_name=region)
 ec2 = session.resource(‘ec2’)
 for rt_id in rts:
   rt = ec2.RouteTable(rt_id)
   for route in rt.routes:
     if (route[‘State’])==’blackhole’:
       print (“affected route table found: “ + rt_id) 
       for assoc_attr in rt.associations_attribute:
         assoc = ec2.RouteTableAssociation(assoc_attr[‘RouteTableAssociationId’]) 
         healthy_rt = get_healthy_rt (rt_id)
         new_assoc = assoc.replace_subnet(DryRun=False,RouteTableId = healthy_rt )
         print (“troubled route table: “ + rt_id +” has been replaced with: “ + healthy_rt )
 
 return True