VERSION = "1.2.0"

treeView = nil
cwd = "."
if OS == "windows" then
    cwd = "./" -- for some reason this works, but "C:" or "%CD%" doesn't
end

function OpenTree()
    local origNum = CurView().Num
    CurView():VSplitIndex(NewBuffer("", ""), 0)
    CurView().Width = 30
    CurView().LockWidth = true
    tabs[curTab+1]:Resize()

    treeView = CurView()
    RefreshTree()
    SetFocus(origNum)
end

function SetFocus(num)
    tabs[curTab+1].CurView = num
end

function RefreshTree()
    treeView.Buf:remove(treeView.Buf:Start(), treeView.Buf:End())
    treeView.Buf:Insert(Loc(0,0), table.concat(scandir(cwd), "\n"))
    treeView.Buf.Settings["softwrap"] = false
    treeView.Buf.Settings["autosave"] = false
    treeView.Buf.Settings["statusline"] = false
    treeView.Buf.IsModified = false
end

-- When user press enter
function preInsertNewline(view)
    if view == treeView then
        local selected = view.Buf:Line(view.Cursor.Loc.Y)
        if isDir(selected) then
            cwd = cwd .. "/" .. selected
            RefreshTree()
        else
            -- TODO: NewBuffer calls NewBufferFromString
            -- ... so manually read file content:
            local filename
            if OS == "windows" then
                -- TODO: The weird "cwd = ./" hack above means we need to cut away "."
                -- ... and set the drive letter manually:
                filename = "C:" .. cwd:sub(2) .. "/" .. selected
            else
                filename = cwd .. "/" .. selected
            end
            local filehandle = io.open(filename, "r")
            if not filehandle then
                messenger:Message("Can't open file:", filename)
                return false
            end
            local filecontent = filehandle:read("*all")
            CurView():VSplitIndex(NewBuffer(filecontent, filename), 0)
            tabs[curTab+1]:Resize()
            SetFocus(CurView().Num)
        end
        return false
    end
    return true
end

-- don't use build-in view.Cursor:SelectLine() as it will copy to clipboard
function SelectLine(v)
    local y = v.Cursor.Loc.Y
    v.Cursor.CurSelection[1] = Loc(0, y)
    v.Cursor.CurSelection[2] = Loc(30, y) -- TODO: 30 => v.Width
end

function onCursorDown(view)
    if view == treeView then SelectLine(view) end
end
function onCursorUp(view)
    if view == treeView then SelectLine(view) end
end

--[[ allows for deleting files
function preDelete(view)
    if view == treeView then
        messenger:YesNoPrompt("Do you want to delete ...?")
        return false
    end
    return true
end
]]--

-- don't prompt to save tree view
function preQuit(view)
    if view == treeView then
        view.Buf.IsModified = false
    end
    return true
end

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile
    if OS == "windows" then
        pfile = popen('dir /a /b "'..directory..'"')
        t[1] = ".." -- add ".." not shown in dir output
        i = 2
        for filename in pfile:lines() do
            t[i] = filename
            i = i + 1
        end
    else
        pfile = popen('ls -aF "'..directory..'"')
        for filename in pfile:lines() do
            if i > 0 then
                -- skip "." dir, (but keep "..")
                t[i] = filename
            end
            i = i + 1
        end
    end
    pfile:close()
    return t
end

function isDir(path)
    local status = false
    local pfile
    if OS == "windows" then
        pfile = io.popen('IF EXIST "'.. cwd .. "/" .. path .. '" ECHO d')
    else
        pfile = io.popen('ls -adl "' .. cwd .. "/" .. path .. '"')
    end
    if pfile:read(1) == "d" then
        status = true
    end
    pfile:close()
    return status
end

MakeCommand("tree", "filetree.OpenTree", 0)
