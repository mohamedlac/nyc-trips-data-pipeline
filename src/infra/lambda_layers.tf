
# ----------------------------------------------------------------------------------------------------------------------
# AWS LAMBDA LAYERS EXPECTS A DEPLOYMENT PACKAGE
# A deployment package is a ZIP archive that contains your dependencies.
# ----------------------------------------------------------------------------------------------------------------------

#resource "null_resource" "package_deploy" {

# provisioner "local-exec" {
#  command = "task lambda:layer:create root_path=${var.requests_layer_root} artifact_file_name=${var.requests_layer_name}"
#}
#}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY THE AWS LAMBDA LAYER
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_layer_version" "requests_layer" {

  filename   = "${path.root}/../aws/lambdas/layers/requests/${var.requests_layer_name}.zip"
  layer_name = var.requests_layer_name

  compatible_runtimes      = var.compatible_layer_runtimes
  compatible_architectures = var.compatible_architectures

  #depends_on = [null_resource.package_deploy]
}