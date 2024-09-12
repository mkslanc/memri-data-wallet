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

// Function to check if the {} brackets are paired
function checkBrackets(fileContent) {
    let balance = 0;

    for (let i = 0; i < fileContent.length; i++) {
        if (fileContent[i] === '{') {
            balance++;
        } else if (fileContent[i] === '}') {
            balance--;
        }

        // If balance goes negative, it means there's an unpaired '}' bracket
        if (balance < 0) {
            return false;
        }
    }

    // If balance is not zero, brackets are unpaired
    return balance === 0;
}

// Function to check files for unpaired brackets
function checkFilesForUnpairedBrackets(dirPath) {
    const allFiles = getAllFiles(dirPath);
    const unpairedFiles = [];

    allFiles.forEach(filePath => {
        const fileContent = fs.readFileSync(filePath, 'utf8');

        if (!checkBrackets(fileContent)) {
            unpairedFiles.push(filePath);
        }
    });

    if (unpairedFiles.length > 0) {
        console.log('Files with unpaired brackets:');
        unpairedFiles.forEach(file => console.log(file));
    } else {
        console.log('All files have properly paired brackets.');
    }
}

// Replace this path with the directory you want to check
const directoryPath = './defaultCVU';

checkFilesForUnpairedBrackets(directoryPath);
