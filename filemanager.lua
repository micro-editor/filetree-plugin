VERSION = "1.3.4"

treeView = nil
cwd = DirectoryName(".")
driveLetter = "C:\\"
isWin = (OS == "windows")
debug = true

-- ToggleTree will toggle the tree view visible (create) and hide (delete).
function ToggleTree()
    if debug == true then messenger:AddLog("***** ToggleTree() *****") end
    if treeView == nil then
        OpenTree()
    else
        CloseTree()
    end
end

-- OpenTree setup's the view
function OpenTree()
    if debug == true then messenger:AddLog("***** OpenTree() *****") end
    CurView():VSplitIndex(NewBuffer("", "FileManager"), 0)
    setupOptions()
    refreshTree()
end

-- setupOptions setup tree view options
function setupOptions()
    if debug == true then messenger:AddLog("***** setupOptions() *****") end
    treeView = CurView()
    treeView.Width = 30
    treeView.LockWidth = true
    -- set options for tree view
    status = SetLocalOption("ruler", "false", treeView)
    if status ~= nil then messenger:Error("Error setting ruler option -> ",status) end
    status = SetLocalOption("softwrap", "true", treeView)
    if status ~= nil then messenger:Error("Error setting softwrap option -> ",status) end
    status = SetLocalOption("autosave", "false", treeView)
    if status ~= nil then messenger:Error("Error setting autosave option -> ", status)  end
    status = SetLocalOption("statusline", "false", treeView)
    if status ~= nil then messenger:Error("Error setting statusline option -> ",status) end
    -- TODO: need to set readonly in view type.
    tabs[curTab+1]:Resize()
end

-- CloseTree will close the tree plugin view and release memory.
function CloseTree()
    if debug == true then messenger:AddLog("***** CloseTree() *****") end
    if treeView ~= nil then
        treeView.Buf.IsModified = false
        treeView:Quit(false)
        treeView = nil
    end
end

-- refreshTree will remove the buffer and load contents from folder
function refreshTree()
    if debug == true then messenger:AddLog("***** refreshTree() *****") end
    -- if debug == true then messenger:AddLog("Start -> ",treeView.Buf:Start()," End -> ",treeView.Buf:End()) end
    treeView.Buf:remove(treeView.Buf:Start(), treeView.Buf:End())
    local list = table.concat(scanDir(cwd), "\n ")
    if debug == true then messenger:AddLog("dir -> ",list) end
    treeView.Buf:Insert(Loc(0,0),list)
end

-- returns currently selected line in treeView
function getSelection()
    if debug == true then messenger:AddLog("***** getSelection() ---> ",treeView.Buf:Line(treeView.Cursor.Loc.Y):sub(2)) end
    return (treeView.Buf:Line(treeView.Cursor.Loc.Y)):sub(2)
end

-- don't use built-in view.Cursor:SelectLine() as it will copy to clipboard (in old versions of Micro)
function selectLineInTree(view)
    if view == treeView then
        if debug == true then messenger:AddLog("***** selectLineInTree(view) *****") end
        local y = view.Cursor.Loc.Y
        view.Cursor.CurSelection[1] = Loc(0, y)
        view.Cursor.CurSelection[2] = Loc(view.Width, y)
    end
end

-- 'beautiful' file selection:
function onCursorDown(view) selectLineInTree(view) end
function onCursorUp(view)   selectLineInTree(view) end

-- mouse callback from micro editor when a left button is clicked on your view
function onMousePress(view, event)
    if view == treeView then  -- check view is tree as only want inputs from that view.
         local columns, rows = event:Position()
         if debug == true then messenger:AddLog("INFO: --> Mouse pressed -> columns location rows location -> ",columns,rows) end
         return false
    end
end

-- disallow selecting topmost line in treeView:
function preCursorUp(view)  
    if view == treeView then
        if debug == true then messenger:AddLog("***** preCursor(view) *****") end
        if view.Cursor.Loc.Y == 1 then
            return false
end end end

-- allows for deleting files
function preDelete(view)
    if view == treeView then
        if debug == true then messenger:AddLog("***** preDelete(view) *****") end
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


-- When user presses enter then if it is a folder clear buffer and reload contents with folder selected.
-- If it is a file then open it in a new vertical view
function preInsertNewline(view)
    if view == treeView then
        if debug == true then messenger:AddLog("***** preInsertNewLine(view)  *****") end
        local selected = getSelection()
        if view.Cursor.Loc.Y == 0 then
            return false -- topmost line is cwd, so disallowing selecting it
        elseif isDir(selected) then  -- if directory then reload contents of tree view
            if debug == true then messenger:AddLog("current working directory -> ",cwd) end
            cwd = JoinPaths(cwd, selected)
            if debug == true then messenger:AddLog("current working directory with selected directory -> ",cwd) end
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

-- don't prompt to save tree view
function preQuit(view)
    if view == treeView then
        if debug == true then messenger:AddLog("***** preQuit(view) *****") end
        view.Buf.IsModified = false
    end
end
function preQuitAll(view) treeView.Buf.IsModified = false end

-- scanDir will scan contents of the directory passed.
function scanDir(directory)
    if debug == true then messenger:AddLog("***** scanDir(directory) ---> ",directory) end
    local i, list, proc = 3, {}, nil
    list[1] = (isWin and driveLetter or "") .. cwd  -- TODO: get current directory working.
    list[2] = ".."  -- used for going up a level in directory.
    if isWin then  -- if windows
        proc = io.popen('dir /a /b "'..directory..'"')
    else           -- linux or unix system
        proc = io.popen('ls -Ap "'..directory..'"')
    end
    -- load filenames to a list
    for filename in proc:lines() do
        list[i] = filename
        i = i + 1
    end
    proc:close()
    return list
end

-- isDir checks if the path passed is a directory.
-- return true if it is a directory else false if it is not a directory.
function isDir(path)
    if debug == true then messenger:AddLog("***** isDir(path) ---> ",path) end
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
    if debug == true then messenger:AddLog("is Dir Return = ",dir) end
    return dir
end

function Test()
    messenger:Error("Current Directory -->",WorkingDirectory())
end

-- micro editor 
MakeCommand("tree", "filemanager.ToggleTree", 0)
MakeCommand("treet","filemanager.Test",0)
AddRuntimeFile("filemanager", "syntax", "syntax.yaml")