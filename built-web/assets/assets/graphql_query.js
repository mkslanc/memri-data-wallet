const fs = require('fs');
const path = require('path');

// Function to get all files recursively in a directory
function getAllFiles(dirPath, arrayOfFiles) {
    const files = fs.readdirSync(dirPath);
    arrayOfFiles = arrayOfFiles || [];

    files.forEach(function (file) {
        if (fs.statSync(path.join(dirPath, file)).isDirectory()) {
            arrayOfFiles = getAllFiles(path.join(dirPath, file), arrayOfFiles);
        } else {
            arrayOfFiles.push(path.join(dirPath, file));
        }
    });

    return arrayOfFiles;
}

// Function to read schema-new.json and extract properties for each itemType
function parseSchema(schemaPath) {
    const schema = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
    const propertiesByType = {};

    schema.forEach(item => {
        if (item.type === 'ItemPropertySchema' || item.type === 'ItemEdgeSchema') {
            const itemType = item.itemType;
            if (!propertiesByType[itemType]) {
                propertiesByType[itemType] = [];
            }
            propertiesByType[itemType].push(item.propertyName);
        }
    });

    return propertiesByType;
}

// Function to replace blocks in files
function replaceBlocksInFile(filePath, propertiesByType) {
    let fileContent = fs.readFileSync(filePath, 'utf8');

    const blockRegex = /\[datasource\s*=\s*pod\]\s*{[^}]*query:\s*"(\w+)"[^}]*}/g;

    fileContent = fileContent.replace(blockRegex, (block, itemType) => {
        const sortPropertyMatch = block.match(/sortProperty:\s*(\w+)/);
        const sortAscendingMatch = block.match(/sortAscending:\s*(\w+)/);
        const filterMatch = block.match(/filter:\s*\{([^\}]*)\}/);

        const sortProperty = sortPropertyMatch ? sortPropertyMatch[1] : null;
        const sortAscending = sortAscendingMatch ? sortAscendingMatch[1] === 'true' : null;
        const filter = filterMatch ? filterMatch[1].trim() : null;

        const order = sortAscending ? 'order_asc' : 'order_desc';
        const properties = propertiesByType[itemType] || [];

        let query = `${itemType} { ${properties.join('\n')} }`;

        if (sortProperty && sortAscending !== null) {
            query = `${itemType} (${order}: ${sortProperty}) { ${properties.join('\n')} }`;
        }

        if (filter) {
            query = `${itemType} (filter: {${filter}}) { ${properties.join('\n')} }`;
        }

        const graphqlQuery = `query { ${query} }`;

        return `[datasource = pod] {
            queryGraphQL: '''${graphqlQuery.trim()}'''
        }`;
    });

    fs.writeFileSync(filePath, fileContent, 'utf8');
}


// Main function to process all files
function processDirectory(dirPath, schemaPath) {
    const allFiles = getAllFiles(dirPath);
    const propertiesByType = parseSchema(schemaPath);

    allFiles.forEach(filePath => {
        replaceBlocksInFile(filePath, propertiesByType);
    });

    console.log('All files processed.');
}

// Replace these paths with your actual paths
const directoryPath = './defaultCVU';
const schemaFilePath = 'schema-new.json';

processDirectory(directoryPath, schemaFilePath);
