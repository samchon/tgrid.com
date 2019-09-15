# CLEAR OLD CONTENTS
rm -rf docs

################################
# GENERATE GUIDE DOCUMENTS
################################
# BUILD GITBOOK
gitbook build

# RENAME DIRECTORY
mv _book docs

# ADD CNAME FILE
echo "tgrid.dev" > ./docs/CNAME

# REMOVE ALL MARKDOWN FILES
find ./docs -type f -name "*.md" -delete

################################
# GENERATE API DOCUMENTS
################################
# REMEMBER CURRENT DIRECTORY
CURRENT="$(pwd)"

# BUILD TYPEDOC
mkdir docs/api
cd ../tgrid
node build/api $CURRENT/docs/api

# TURN BACK TO CURRENT DIRECTORY
cd $CURRENT