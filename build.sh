# CLEAR OLD CONTENTS
rm -rf docs

################################
# GENERATE GUIDE DOCUMENTS
################################
# BUILD GITBOOK
gitbook build

# RENAME DIRECTORY
mv _book docs

# ADD CUSTOM FILES
\cp assets/customs/* docs/

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
npm run api $CURRENT/docs/api

# TURN BACK TO CURRENT DIRECTORY
cd $CURRENT