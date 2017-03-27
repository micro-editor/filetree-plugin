VERSION = "1.3.4"

treeView = nil
cwd = DirectoryName(".")
driveLetter = "C:\\"
isWin = (OS == "windows")

function OpenTree()
    CurView():VSplitIndex(NewBuffer("", ""), 0)
    treeView = CurView()
    treeView.Width = 30
    treeView.LockWidth = true
    SetLocalOption("ruler", "false", treeView)
    SetLocalOption("softwrap", "true", treeView)
    SetLocalOption("autosave", "false", treeView)
    SetLocalOption("statusline", "false", treeView)
    SetLocalOption("readonly", "true", treeView)
    tabs[curTab+1]:Resize()
    refreshTree()
end

function CloseTree()
    if treeView ~= nil then
        treeView.Buf.IsModified = false
        treeView:Quit(false)
        treeView = nil
    end
end

function ToggleTree()
    if treeView == nil then
        OpenTree()
    else
        CloseTree()
    end
end

function refreshTree()
    treeView.Buf:remove(treeView.Buf:Start(), treeView.Buf:End())
    treeView.Buf:Insert(Loc(0,0), table.concat(scanDir(cwd), "\n "))
end

-- returns currently selected line in treeView
function getSelection()
    return (treeView.Buf:Line(treeView.Cursor.Loc.Y)):sub(2)
end

-- When user press enter
function preInsertNewline(view)
    if view == treeView then
        local selected = getSelection()
        if view.Cursor.Loc.Y == 0 then
            return false -- topmost line is cwd, so disallowing selecting it
        elseif isDir(selected) then
            cwd = JoinPaths(cwd, selected)
            refreshTree()
        else
            local filename = JoinPaths(cwd, selected)
            if isWin then filename = driveLetter .. filename end
            CurView():VSplitIndex(NewBuffer("", filename), 1)
            CurView():ReOpen()
            tabs[curTab+1]:Resize()
        end
        return false
    end
    return true
end

-- disallow selecting topmost line in treeview:
function preCursorUp(view) 
    if view == treeView then
        if view.Cursor.Loc.Y == 1 then
            return false
end end end

-- don't use build-in view.Cursor:SelectLine() as it will copy to clipboard (in old versions of Micro)
function selectLineInTree(v)
    if v == treeView then
        local y = v.Cursor.Loc.Y
        v.Cursor.CurSelection[1] = Loc(0, y)
        v.Cursor.CurSelection[2] = Loc(v.Width, y)
    end
end

-- 'beautiful' file selection:
function onCursorDown(view) selectLineInTree(view) end
function onCursorUp(view)   selectLineInTree(view) end

-- allows for deleting files
function preDelete(view)
    if view == treeView then
        local selected = getSelection()
        if selected == ".." then return false end
        local type, command
        if isDir(selected) then
            type = "dir"
            command = isWin and "del /S /Q" or "rm -r"
        else
            type = "file"
            command = isWin and "del" or "rm -I"
        end
        command = command .. " " .. (isWin and driveLetter or "") .. JoinPaths(cwd, selected)

        local yes, cancel = messenger:YesNoPrompt("Do you want to delete " .. type .. " '" .. selected .. "'? ")
        if not cancel and yes then
            os.execute(command)
            refreshTree()
        end
        -- Clears messenger:
        messenger:Reset()
        messenger:Clear()
        return false -- don't "allow" delete
    end
end

-- don't prompt to save tree view
function preQuit(view)
    if view == treeView then
        view.Buf.IsModified = false
    end
end
function preQuitAll(view) treeView.Buf.IsModified = false end

function scanDir(directory)
    local i, t, proc = 3, {}, nil
    t[1] = (isWin and driveLetter or "") .. cwd
    t[2] = ".."
    if isWin then
        proc = io.popen('dir /a /b "'..directory..'"')
    else
        proc = io.popen('ls -Ap "'..directory..'"')
    end
    for filename in proc:lines() do
        t[i] = filename
        i = i + 1
    end
    proc:close()
    return t
end

function isDir(path)
    local dir, proc = false, nil
    if isWin then
        proc = io.popen('IF EXIST ' .. driveLetter .. JoinPaths(cwd, path) .. '/* (ECHO d) ELSE (ECHO -)')
    else
        proc = io.popen('ls -adl "' .. JoinPaths(cwd, path) .. '"')
    end
    if proc:read(1) == "d" then
        dir = true
    end
    proc:close()
    return dir
end

MakeCommand("tree", "filemanager.ToggleTree", 0)
AddRuntimeFile("filemanager", "syntax", "syntax.yaml")
