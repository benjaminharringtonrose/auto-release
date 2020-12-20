#!/bin/bash

# 1. get the current branch and project name
# 2. checkout current branch
# 3. develop branch validation
# 4. release version validation
# 5. get package version
# 5. pull the latest code from develop
# 6. create empty commit from develop
# 7. create tag for new version from develop
# 8. push commit to remote origin
# 9. push tag to remote origin
# 10. create the release branch from the develop branch
# 11. push local release branch to remote
# 12. merge develop branch
# 13. push commit release branch to remote origin

BLUE_TEXT='\033[0;34m'
RED_TEXT='\033[0;31m'
PURPLE_TEXT='\033[0;35m'
NO_COLOR='\033[0m'

# current Git branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# current project name
projectName=$(git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p')

# establish develop branch name and develop variables
developBranch=$branch

# checkout to develop branch, this will break if the user has uncommited changes
git checkout $developBranch

# master branch validation
if [ $branch = "develop" ]; then

	printf ${PURPLE_TEXT}"\nHave you already incremented the package.json? y/n ${NO_TEXT}"
	read userResponse

	if [ $userResponse == "y" ]; then

		# Version value
		PACKAGE_VERSION=$(cat package.json \
			| grep version \
			| head -1 \
			| awk -F: '{ print $2 }' \
			| sed 's/[",]//g' \
			| tr -d '[:space:]')

		printf ${PURPLE_TEXT}"\nRelease version $PACKAGE_VERSION${NO_TEXT}\n\n"

		# 1.0.0, 1.0.1, 1.1.0, etc
		versionLabel=$PACKAGE_VERSION

		# establish branch and tag name variables
		releaseBranch="release/$PACKAGE_VERSION"
		tagName="open-release-v$PACKAGE_VERSION"

		printf "\n${BLUE_TEXT}Started releasing $PACKAGE_VERSION for $projectName -->${NO_COLOR}\n\n"

		# pull the latest version of the code from develop and create empty commit from develop branch
		printf "\n${BLUE_TEXT}git pull && git commit --allow-empty -m${NO_COLOR}\n\n"
		git pull && git commit --allow-empty -m "Creating branch $releaseBranch"

		# create tag for new version from develop and push commit to remote origin
		printf "\n${BLUE_TEXT}git tag $tagName && git push${NO_COLOR}\n\n"
		git tag $tagName && git push

		# push tag to remote origin
		printf "\n${BLUE_TEXT}git push --tags origin${NO_COLOR}\n\n"
		git push --tags origin 
		
		# create the release branch from the develop branch
		printf "\n${BLUE_TEXT}git checkout -b $releaseBranch $developBranch ${NO_COLOR}\n\n"
		git checkout -b $releaseBranch $developBranch

		# merge develop branch
		printf "\n${BLUE_TEXT}git merge $developBranch ${NO_COLOR}\n\n"		
		git merge $developBranch

		# push local releaseBranch to remote
		git push -u origin $releaseBranch

		printf "\n${PURPLE_TEXT}$PACKAGE_VERSION is successfully created for $projectName!${NO_COLOR}\n\n"

	elif [ $userResponse == "n" ]; then

		printf "\n${RED_TEXT}Error: Please increment package${NO_COLOR}\n\n"

	else

		printf "\n${RED_TEXT}Error: Incorrect response${NO_COLOR}\n\n"

	fi

else 

	printf "${RED_TEXT}Please make sure you are on develop branch!${NO_COLOR}\n"

fi