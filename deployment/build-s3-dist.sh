#!/bin/bash

# This script should be run from the repo's deployment directory
# cd deployment
# ./build-s3-dist.sh source-bucket-base-name
# source-bucket-base-name should be the base name for the S3 bucket location where the template will source the Lambda code from.
# The template will append '-[region_name]' to this bucket name.
# For example: ./build-s3-dist.sh solutions
# The template will then expect the source code to be located in the solutions-[region_name] bucket

# Check to see if input has been provided:
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]|| [ -z "$4" ] ; then
    echo "Please provide the base source bucket name, open-source bucket name, trademark approved solution name and version where the lambda code will eventually reside."
    echo "For example: ./build-s3-dist.sh solutions solutions-github trademarked-solution-name v1.0.0"
    exit 1
fi

# Get reference for all important folders
template_dir="$PWD"
template_dist_dir="$template_dir/global-s3-assets"
build_dist_dir="$template_dir/regional-s3-assets"
source_dir="$template_dir/../source"

echo "------------------------------------------------------------------------------"
echo "[Init] Clean old dist folders"
echo "------------------------------------------------------------------------------"
echo "rm -rf $template_dist_dir"
rm -rf $template_dist_dir
echo "mkdir -p $template_dist_dir"
mkdir -p $template_dist_dir
echo "rm -rf $build_dist_dir"
rm -rf $build_dist_dir
echo "mkdir -p $build_dist_dir"
mkdir -p $build_dist_dir


# Build source
echo "Staring to build distribution"
# Create variable for deployment directory to use as a reference for builds
echo "export deployment_dir=`pwd`"
export deployment_dir=`pwd`

# # Make deployment/dist folder for containing the built solution
# echo "mkdir -p $deployment_dir/dist"
# mkdir -p $deployment_dir/dist

echo "------------------------------------------------------------------------------"
echo "[Packing] Templates"
echo "------------------------------------------------------------------------------"
echo "cp $template_dir/predictive-maintenance-using-machine-learning.yaml $template_dist_dir/predictive-maintenance-using-machine-learning.template"
cp $template_dir/predictive-maintenance-using-machine-learning.yaml $template_dist_dir/predictive-maintenance-using-machine-learning.template

echo "Updating template in template with $1"
replace="s/%%TEMPLATE_BUCKET_NAME%%/$1/g"
echo "sed -i '' -e $replace $template_dist_dir/predictive-maintenance-using-machine-learning.template"
sed -i '' -e $replace $template_dist_dir/predictive-maintenance-using-machine-learning.template

echo "Updating code source bucket in template with $2"
replace="s/%%BUCKET_NAME%%/$2/g"
echo "sed -i '' -e $replace $template_dist_dir/predictive-maintenance-using-machine-learning.template"
sed -i '' -e $replace $template_dist_dir/predictive-maintenance-using-machine-learning.template


replace="s/%%SOLUTION_NAME%%/$3/g"
echo "sed -i '' -e $replace $template_dist_dir/predictive-maintenance-using-machine-learning.template"
sed -i '' -e $replace $template_dist_dir/predictive-maintenance-using-machine-learning.template

replace="s/%%VERSION%%/$4/g"
echo "sed -i '' -e $replace $template_dist_dir/predictive-maintenance-using-machine-learning.template"
sed -i '' -e $replace $template_dist_dir/predictive-maintenance-using-machine-learning.template



# Copy website files to $deployment_dir/dist
echo "Copying notebooks to $deployment_dir/dist"
cp -r $deployment_dir/../source/notebooks $build_dist_dir/

# Package fraud_detection Lambda function
echo "Packaging predictive_maintenance lambda"
cd $source_dir/predictive_maintenance/

zip -q -r9 predictive_maintenance.zip *
cp predictive_maintenance.zip $build_dist_dir/
rm predictive_maintenance.zip

# Done, so go back to deployment_dir
echo "Completed building distribution"
cd $deployment_dir
