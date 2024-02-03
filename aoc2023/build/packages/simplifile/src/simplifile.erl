-module(simplifile).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function]).

-export([read/1, write/2, delete/1, delete_all/1, append/2, read_bits/1, write_bits/2, append_bits/2, is_directory/1, create_directory/1, read_directory/1, is_file/1, create_file/1, get_files/1, create_directory_all/1, copy_directory/2, rename_directory/2, copy_file/2, rename_file/2]).
-export_type([file_error/0]).

-type file_error() :: eacces |
    eagain |
    ebadf |
    ebadmsg |
    ebusy |
    edeadlk |
    edeadlock |
    edquot |
    eexist |
    efault |
    efbig |
    eftype |
    eintr |
    einval |
    eio |
    eisdir |
    eloop |
    emfile |
    emlink |
    emultihop |
    enametoolong |
    enfile |
    enobufs |
    enodev |
    enolck |
    enolink |
    enoent |
    enomem |
    enospc |
    enosr |
    enostr |
    enosys |
    enotblk |
    enotdir |
    enotsup |
    enxio |
    eopnotsupp |
    eoverflow |
    eperm |
    epipe |
    erange |
    erofs |
    espipe |
    esrch |
    estale |
    etxtbsy |
    exdev |
    not_utf8 |
    unknown.

-spec do_append(binary(), binary()) -> {ok, nil} | {error, file_error()}.
do_append(Content, Filepath) ->
    _pipe = Content,
    _pipe@1 = gleam_stdlib:identity(_pipe),
    simplifile_erl:append_file(_pipe@1, Filepath).

-spec do_write(binary(), binary()) -> {ok, nil} | {error, file_error()}.
do_write(Content, Filepath) ->
    _pipe = Content,
    _pipe@1 = gleam_stdlib:identity(_pipe),
    simplifile_erl:write_file(_pipe@1, Filepath).

-spec do_read(binary()) -> {ok, binary()} | {error, file_error()}.
do_read(Filepath) ->
    case simplifile_erl:read_file(Filepath) of
        {ok, Bits} ->
            case gleam@bit_array:to_string(Bits) of
                {ok, Str} ->
                    {ok, Str};

                _ ->
                    {error, not_utf8}
            end;

        {error, E} ->
            {error, E}
    end.

-spec cast_error({ok, FIL} | {error, file_error()}) -> {ok, FIL} |
    {error, file_error()}.
cast_error(Input) ->
    Input.

-spec read(binary()) -> {ok, binary()} | {error, file_error()}.
read(Filepath) ->
    _pipe = do_read(Filepath),
    cast_error(_pipe).

-spec write(binary(), binary()) -> {ok, nil} | {error, file_error()}.
write(Filepath, Contents) ->
    _pipe = do_write(Contents, Filepath),
    cast_error(_pipe).

-spec delete(binary()) -> {ok, nil} | {error, file_error()}.
delete(Path) ->
    _pipe = simplifile_erl:recursive_delete(Path),
    cast_error(_pipe).

-spec delete_all(list(binary())) -> {ok, nil} | {error, file_error()}.
delete_all(Paths) ->
    case Paths of
        [] ->
            {ok, nil};

        [Path | Rest] ->
            case delete(Path) of
                {ok, nil} ->
                    delete_all(Rest);

                {error, enoent} ->
                    delete_all(Rest);

                E ->
                    E
            end
    end.

-spec append(binary(), binary()) -> {ok, nil} | {error, file_error()}.
append(Filepath, Contents) ->
    _pipe = do_append(Contents, Filepath),
    cast_error(_pipe).

-spec read_bits(binary()) -> {ok, bitstring()} | {error, file_error()}.
read_bits(Filepath) ->
    _pipe = simplifile_erl:read_file(Filepath),
    cast_error(_pipe).

-spec write_bits(binary(), bitstring()) -> {ok, nil} | {error, file_error()}.
write_bits(Filepath, Bits) ->
    _pipe = simplifile_erl:write_file(Bits, Filepath),
    cast_error(_pipe).

-spec append_bits(binary(), bitstring()) -> {ok, nil} | {error, file_error()}.
append_bits(Filepath, Bits) ->
    _pipe = simplifile_erl:append_file(Bits, Filepath),
    cast_error(_pipe).

-spec is_directory(binary()) -> boolean().
is_directory(Filepath) ->
    filelib:is_dir(Filepath).

-spec create_directory(binary()) -> {ok, nil} | {error, file_error()}.
create_directory(Filepath) ->
    _pipe = simplifile_erl:make_directory(Filepath),
    cast_error(_pipe).

-spec read_directory(binary()) -> {ok, list(binary())} | {error, file_error()}.
read_directory(Path) ->
    _pipe = simplifile_erl:list_directory(Path),
    cast_error(_pipe).

-spec is_file(binary()) -> boolean().
is_file(Filepath) ->
    simplifile_erl:is_file(Filepath).

-spec create_file(binary()) -> {ok, nil} | {error, file_error()}.
create_file(Filepath) ->
    case begin
        _pipe = Filepath,
        is_file(_pipe)
    end
    orelse begin
        _pipe@1 = Filepath,
        is_directory(_pipe@1)
    end of
        true ->
            {error, eexist};

        false ->
            write_bits(Filepath, <<>>)
    end.

-spec do_copy_directory(binary(), binary()) -> {ok, nil} | {error, file_error()}.
do_copy_directory(Src, Dest) ->
    gleam@result:'try'(
        read_directory(Src),
        fun(Segments) ->
            _pipe = Segments,
            gleam@list:each(
                _pipe,
                fun(Segment) ->
                    Src_path = <<<<Src/binary, "/"/utf8>>/binary,
                        Segment/binary>>,
                    Dest_path = <<<<Dest/binary, "/"/utf8>>/binary,
                        Segment/binary>>,
                    case {is_file(Src_path), is_directory(Src_path)} of
                        {true, false} ->
                            gleam@result:'try'(
                                read_bits(Src_path),
                                fun(Content) -> _pipe@1 = Content,
                                    write_bits(Dest_path, _pipe@1) end
                            );

                        {false, true} ->
                            gleam@result:'try'(
                                create_directory(Dest_path),
                                fun(_) ->
                                    do_copy_directory(Src_path, Dest_path)
                                end
                            );

                        {_, _} ->
                            erlang:error(#{gleam_error => panic,
                                    message => <<"unreachable"/utf8>>,
                                    module => <<"simplifile"/utf8>>,
                                    function => <<"do_copy_directory"/utf8>>,
                                    line => 341})
                    end
                end
            ),
            {ok, nil}
        end
    ).

-spec get_files(binary()) -> {ok, list(binary())} | {error, file_error()}.
get_files(Directory) ->
    gleam@result:'try'(
        read_directory(Directory),
        fun(Contents) ->
            Paths = gleam@list:map(
                Contents,
                fun(Segment) ->
                    <<<<Directory/binary, "/"/utf8>>/binary, Segment/binary>>
                end
            ),
            Files = gleam@list:filter(Paths, fun is_file/1),
            case gleam@list:filter(Paths, fun is_directory/1) of
                [] ->
                    {ok, Files};

                Directories ->
                    gleam@result:'try'(
                        gleam@list:try_map(Directories, fun get_files/1),
                        fun(Nested_files) ->
                            {ok,
                                gleam@list:append(
                                    Files,
                                    gleam@list:flatten(Nested_files)
                                )}
                        end
                    )
            end
        end
    ).

-spec create_directory_all(binary()) -> {ok, nil} | {error, file_error()}.
create_directory_all(Dirpath) ->
    Path = case begin
        _pipe = Dirpath,
        gleam@string:ends_with(_pipe, <<"/"/utf8>>)
    end of
        true ->
            Dirpath;

        false ->
            <<Dirpath/binary, "/"/utf8>>
    end,
    _pipe@1 = simplifile_erl:create_dir_all(Path),
    cast_error(_pipe@1).

-spec copy_directory(binary(), binary()) -> {ok, nil} | {error, file_error()}.
copy_directory(Src, Dest) ->
    gleam@result:'try'(
        create_directory_all(Dest),
        fun(_) -> do_copy_directory(Src, Dest) end
    ).

-spec rename_directory(binary(), binary()) -> {ok, nil} | {error, file_error()}.
rename_directory(Src, Dest) ->
    gleam@result:'try'(copy_directory(Src, Dest), fun(_) -> delete(Src) end).

-spec copy_file(binary(), binary()) -> {ok, nil} | {error, file_error()}.
copy_file(Src, Dest) ->
    _pipe = file:copy(Src, Dest),
    _pipe@1 = gleam@result:replace(_pipe, nil),
    cast_error(_pipe@1).

-spec rename_file(binary(), binary()) -> {ok, nil} | {error, file_error()}.
rename_file(Src, Dest) ->
    _pipe = simplifile_erl:rename_file(Src, Dest),
    cast_error(_pipe).
