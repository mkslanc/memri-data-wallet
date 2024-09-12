const fs = require('fs');

// Load the input schema from the file
const inputSchema = JSON.parse(fs.readFileSync('schema.json', 'utf8'));

const valueTypeMapping = {
  string: "Text",
  int: "Integer",
  datetime: "DateTime",
  double: "Real",
  bool: "Bool"
};

const outputSchema = {
  meta: {
    name: "memriOne",
    url: "https://gitlab.memri.io/memri/consumer_app",
    version: "0.1"
  },
  nodes: {},
  edges: {}
};

inputSchema.properties.forEach(prop => {
  if (!outputSchema.nodes[prop.item_type]) {
    outputSchema.nodes[prop.item_type] = { properties: {} };
  }
  const mappedValueType = valueTypeMapping[prop.value_type] || prop.value_type;
  outputSchema.nodes[prop.item_type].properties[prop.property] = mappedValueType;
});

inputSchema.edges.forEach(edge => {
  if (!outputSchema.edges[edge.edge]) {
    outputSchema.edges[edge.edge] = [];
  }
  outputSchema.edges[edge.edge].push({
    source: edge.source_type,
    target: edge.target_type
  });
});

// Save the output schema to a file
fs.writeFileSync('outputSchema.json', JSON.stringify(outputSchema, null, 2));

console.log('Schema converted successfully and saved to outputSchema.json');
