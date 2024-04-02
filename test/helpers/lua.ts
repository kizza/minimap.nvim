const convert = (value: unknown): string => {
  if (typeof value === 'string') {
    return `"${value.replace(/"/g, '\\"')}"`;
  } else if (typeof value === 'boolean' || typeof value === 'number') {
    return value.toString();
  } else if (Array.isArray(value)) {
    return `{${value.map(convert).join(', ')}}`;
  } else if (typeof value === 'object' && value !== null) {
    return stringify(value);
  } else {
    return 'nil';
  }
};

export const stringify = (obj: any) => {
  const isLuaIdentifier = (key: string) => /^[A-Za-z_]\w*$/.test(key);

  const table = Object.entries(obj).reduce((acc, [key, value], index, array) => {
    const formattedKey = isLuaIdentifier(key) ? key : `["${key}"]`;
    const element = `${formattedKey} = ${convert(value)}`;
    const separator = index < array.length - 1 ? ', ' : '';
    return acc + element + separator;
  }, "");

  return `{${table}}`;
}
