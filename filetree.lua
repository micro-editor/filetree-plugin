VERSION = "1.0.1"

treeView = nil
cwd = "."

function OpenTree()
    local origNum = CurView().Num
    CurView():VSplitIndex(NewBuffer("", ""), 0)
    CurView().Width = 30
    CurView().LockWidth = true
    tabs[curTab+1]:Resize()

    treeView = CurView()
    RefreshTree()
    LoseFocus(origNum)
end

function LoseFocus(num)
    tabs[curTab+1].CurView = num + 1
end

function RefreshTree()
    --if treeView == nil then OpenTree() end
    treeView.Buf:remove(treeView.Buf:Start(), treeView.Buf:End())
    treeView.Buf:Insert(Loc(0,0), table.concat(scandir(cwd), "\n"))
    treeView.Buf.Settings["softwrap"] = false
    treeView.Buf.Settings["autosave"] = false
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
            local filename = cwd .. "/" .. selected
            local filehandle = io.open(filename, "r")
            if not filehandle then
                TermMessage("Can't open file:", filename)
            end
            local filecontent = filehandle:read("*all")
            CurView():VSplitIndex(NewBuffer(filecontent, filename), 0)
            tabs[curTab+1]:Resize()
            LoseFocus(CurView().Num)
        end
        return false
    end
    return true
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
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function isDir(path)
    local pfile = io.popen('ls -adl "' .. cwd .. "/" .. path .. '"')
    local status = false
    if pfile:read(1) == "d" then
        status = true
    end
    pfile:close()
    return status
end

MakeCommand("tree", "filetree.OpenTree", 0)
