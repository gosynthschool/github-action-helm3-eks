#!/bin/sh

set -e

if [ -z "$INPUT_KUBECONFIG" ]; then
    echo "INPUT_KUBECONFIG is not set. EKS will not be called."
else

if [ -z "$INPUT_AWS_ACCESS_KEY_ID" ]; then
  echo "INPUT_AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
else
INPUT_AWS_ACCESS_KEY_ID=$(echo "${INPUT_AWS_ACCESS_KEY_ID}" | xargs)
fi

if [ -z "$INPUT_AWS_SECRET_ACCESS_KEY" ]; then
  echo "INPUT_AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
else
INPUT_AWS_SECRET_ACCESS_KEY=$(echo "${INPUT_AWS_SECRET_ACCESS_KEY}" | xargs)
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$INPUT_AWS_REGION" ]; then
  AWS_REGION="us-east-2"
fi

# Create a dedicated profile for this action to avoid conflicts
# with past/future actions.
aws configure --profile github_user <<-EOF > /dev/null 2>&1
${INPUT_AWS_ACCESS_KEY_ID}
${INPUT_AWS_SECRET_ACCESS_KEY}
${INPUT_AWS_REGION}
text
EOF

echo -e "\033[36mSetting up kubectl configuration\033[0m"
mkdir -p ~/.kube/
echo "${INPUT_KUBECONFIG}" > ~/.kube/config

fi

echo -e "\033[36mPreparing helm execution\033[0m"
echo "${INPUT_EXEC}" > run.sh
chmod +x ./run.sh

echo -e "\033[36mExecuting helm\033[0m"
helm_output=$(./run.sh)
echo "$helm_output"
mkdir -p _temp
printf "# Helm Results\n\n\`\`\`bash\n%s\n\`\`\`" $helm_output > ./_temp/helm_output

helm_output="${helm_output//'%'/'%25'}"
helm_output="${helm_output//$'\n'/'%0A'}"
helm_output="${helm_output//$'\r'/'%0D'}"

echo "::set-output name=helm_output::$helm_output"

echo -e "\033[36mCleaning up: \033[0m"
rm ./run.sh -Rf
echo -e "\033[36m  - exec ✅ \033[0m"
rm ~/.kube/config -Rf
echo -e "\033[36m  - kubeconfig ✅ \033[0m"
