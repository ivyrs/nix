{
  runCommand,
  cclip,
  sqlite,
}:
runCommand "cclip-database-test"
  {
    nativeBuildInputs = [
      cclip
      sqlite
    ];
  }
  ''
    export HOME="$TMPDIR/home"
    export XDG_DATA_HOME="$HOME/data"
    export XDG_RUNTIME_DIR="$TMPDIR/runtime"
    export WAYLAND_DISPLAY=missing-test-display
    mkdir -m 700 -p "$HOME" "$XDG_RUNTIME_DIR"
    db="$XDG_DATA_HOME/cclip/db.sqlite3"

    # No compositor or real clipboard: initialization must still create a
    # private database, without needing install on the caller's PATH.
    if PATH=/nonexistent ${cclip}/bin/cclipd 2>daemon.log; then
      echo "unexpected connection to a Wayland server" >&2
      exit 1
    fi
    test "$(stat -c %a "$db")" = 600
    test "$(sqlite3 "$db" 'PRAGMA user_version')" = 4

    sqlite3 "$db" <<'SQL'
    INSERT INTO history VALUES
      (1, CAST('first' || char(10) || 'second' || char(10) AS BLOB),
       13, 101, 'multiline text', 'text/plain', 100),
      (2, X'0001FF', 3, 102, 'binary data', 'image/png', 200);
    SQL

    cclip get 1 > actual
    printf 'first\nsecond\n' > expected
    cmp expected actual
    cclip get 2 > actual
    printf '\000\001\377' > expected
    cmp expected actual

    # This is the preferred field set used by our pinned fsel release.
    cclip tag 1 test-tag
    cclip list 'rowid,mime_type,preview,data_size,timestamp,tag' > entries
    grep -Fx "$(printf '1\ttext/plain\tmultiline text\t13\t100\ttest-tag')" entries

    touch "$out"
  ''
