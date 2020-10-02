
(() => {
    const fs = require("fs")
    const 原代码 = fs.readFileSync("src/calibre/db/backend.py", "utf8")
    let 替换后 = 原代码
    替换后 = 替换后.replace(替换后.match(
        '# Imports {{{')[0],
        '# Imports {{{\nimport re\n')
    let k = 2;
    while (--k) {
        替换后 = 替换后.replace(替换后.match(
            /author = ascii_filename.*/)[0],
            `author = re.sub(r"[\\/\\\\\\:\\*\\?\\"\\<\\>\\|]", "_", author.strip())[:l]`)
        替换后 = 替换后.replace(替换后.match(
            /title  = ascii_filename.*/)[0],
            `title  = re.sub(r"[\\/\\\\\\:\\*\\?\\"\\<\\>\\|]", "_", title.strip())[:l]`)
    }
    const outputPath = "src/calibre/db/backend_new.py"
    fs.writeFileSync(outputPath, 替换后)
    console.log('done: ', outputPath)
    process.exit(0)
})()