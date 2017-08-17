VERSION = "1.3.4"

treeView = nil
cwd = DirectoryName(".")
driveLetter = "C:\\"
isWin = (OS == "windows")
debug = true

-- ToggleTree will toggle the tree view visible (create) and hide (delete).
function ToggleTree()
    if debug == true then messenger:AddLog("<--- ToggleTree()  --->") end
    if treeView == nil then
        OpenTree()
    else
        CloseTree()
    end
end

-- OpenTree setup's the view
function OpenTree()
    if debug == true then messenger:AddLog("<--- OpenTree()  --->") end
    CurView():VSplitIndex(NewBuffer("", "FileManager"), 0)
    setupOptions()
    refreshTree()
end

-- setupOptions setup tree view options
function setupOptions()
    if debug == true then messenger:AddLog("<--- setupOptions()  --->") end
    treeView = CurView()
    treeView.Width = 30
    treeView.LockWidth = true
    -- set options for tree view
    status = SetLocalOption("ruler", "false", treeView)
    if status ~= nil then messenger:AddLog("ruler -> ",status) end
    status = SetLocalOption("softwrap", "true", treeView)
    if status ~= nil then messenger:AddLog("softwrap -> ",status) end
    status = SetLocalOption("autosave", "false", treeView)
    if status ~= nil then messenger:AddLog("autosave -> ", status)  end
    status = SetLocalOption("statusline", "false", treeView)
    if status ~= nil then messenger:AddLog("statusline -> ",status) end
    messenger:Error("Error -> ",treeView.Type)
    tabs[curTab+1]:Resize()
end

-- mouse callback from micro editor when a left button is clicked on your view
function onMousePress(view, event)
    local columns, rows = event:Position()
    if debug == true then messenger:AddLog("columns location rows location ",columns,rows) end
end

-- CloseTree will close the tree plugin view and release memory.
function CloseTree()
    if debug == true then messenger:AddLog("<--- CloseTree()  --->") end
    if treeView ~= nil then
        treeView.Buf.IsModified = false
        treeView:Quit(false)
        treeView = nil
    end
end



-- refreshTree will remove the buffer and load contents from folder
function refreshTree()
    if debug == true then messenger:AddLog("<--- refreshTree()  --->") end
    treeView.Buf:remove(treeView.Buf:Start(), treeView.Buf:End())
    treeView.Buf:Insert(Loc(0,0), table.concat(scanDir(cwd), "\n "))
end

-- returns currently selected line in treeView
function getSelection()
    if debug == true then messenger:AddLog("<--- getSelection()  --->") end
    return (treeView.Buf:Line(treeView.Cursor.Loc.Y)):sub(2)
end

-- When user presses enter then if it is a folder clear buffer and reload contents with folder selected.
-- If it is a file then open it in a new vertical view
function preInsertNewline(view)
    if debug == true then messenger:AddLog("<--- preInsertNewLine(view) %v --->",view) end
    if view == treeView then
        local selected = getSelection()
        if view.Cursor.Loc.Y == 0 then
            return false -- topmost line is cwd, so disallowing selecting it
        elseif isDir(selected) then  -- if directory then reload contents of tree view
            cwd = JoinPaths(cwd, selected)
            refreshTree()
        else  -- open file in new vertical view
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

-- disallow selecting topmost line in treeView:
function preCursorUp(view) 
    if debug == true then messenger:AddLog("<--- preCursor(view)  %v  --->",view) end
    if view == treeView then
        if view.Cursor.Loc.Y == 1 then
            return false
end end end

-- don't use built-in view.Cursor:SelectLine() as it will copy to clipboard (in old versions of Micro)
function selectLineInTree(v)
    if debug == true then messenger:AddLog("<--- selectLineInTree(v) %v  --->",v) end
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
    if debug == true then messenger:AddLog("<--- preDelete(view) %v  --->",view) end
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
    if debug == true then messenger:AddLog("<--- preQuit(view) %v  --->",view) end
    if view == treeView then
        view.Buf.IsModified = false
    end
end
function preQuitAll(view) treeView.Buf.IsModified = false end

-- scanDir will scan contents of the directory passed.
function scanDir(directory)
    if debug == true then messenger:AddLog("<--- scanDir(directory) %v  --->",directory) end
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

-- isDir checks if the path passed is a directory.
-- return true if it is a directory else false if it is not a directory.
function isDir(path)
    if debug == true then messenger:AddLog("<--- isDir(path) %v  --->",path) end
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

-- micro editor 
MakeCommand("tree", "filemanager.ToggleTree", 0)
AddRuntimeFile("filemanager", "syntax", "syntax.yaml")
