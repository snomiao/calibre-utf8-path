# encoding: utf8
def main():
    f = open('src/calibre/db/backend.py', 'r', encoding="utf-8")
    source = f.read()
    target = source
    target = target.replace(
        '# Imports {{{', '# Imports {{{\nimport re\n'
    )
    target = target.replace(
        'author = ascii_filename(author)[:l]',
        'author = re.sub(r"[\\/\\\\\\:\\*\\?\\"\\<\\>\\|]", "_", author.strip())[:l]'
    )
    if(source == target):
        return("WARNING: REPLACE AUTHOR FILENAME FAILS")

    source = target
    target = target.replace(
        'title  = ascii_filename(title.lstrip())[:l].rstrip()',
        'title  = re.sub(r"[\\/\\\\\\:\\*\\?\\"\\<\\>\\|]", "_", title.strip())[:l]'
    )
    if(source == target):
        return("WARNING: REPLACE TITLE FILENAME FAILS")
    f.close()

    f = open('src/calibre/db/backend_new.py', 'w', encoding="utf-8")
    f.write(target)
    return 'done'


if __name__ == "__main__":
    print(main())
