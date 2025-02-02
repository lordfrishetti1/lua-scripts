function plugindef()


    finaleplugin.Author = "Jacob Winkler"
    finaleplugin.Copyright = "2022"
    finaleplugin.Version = "1.0.1"
    finaleplugin.Date = "2022-09-25"
    finaleplugin.RequireSelection = true
    finaleplugin.AuthorEmail = "jacob.winkler@mac.com"
    finaleplugin.Notes = [[
    This plug-in is intended to aid in producing scores with multi-instrument staves.

    - In any given selected measure, if the plugin finds no entries in layer 1 but entries in other layers, it will add a whole rest in layer 1.
    - The same for layer 2.
    - If the time signature of the measure is anything other than 4/4, the whole note will be made into a tuplet lasting the entire measure. This will prevent Finale from complaining about the rest being too long, or filling the measure with more rests, according to the current settings.

    - The tuplet will be hidden, but the hidden number '1' will still be shown as a visual reminder of the tuplet.

    NOTE: Finale *might* exhibit some odd behavior when copying/pasting single-note tuplets!

    ]]
    finaleplugin.HashURL = "https://raw.githubusercontent.com/finale-lua/lua-scripts/master/hash/layers_create_whole_rests_1_2.hash"
    return "Layers: Create Whole Rests (1, 2)", "Layers: Create Whole Rests (1, 2)", "Creates whole rest tuplets in layers 1 and 2 if it finds music in any other layers."
end
local region = finenv.Region()
local layer = 2
function layer_add_whole_rest_tuplet(region, layer)
    for cell_measure, cell_staff in eachcell(region) do
        local cell = finale.FCCell(cell_measure, cell_staff)
        local note_entry_layer = finale.FCNoteEntryLayer(layer - 1, cell_staff, cell_measure, cell_measure)
        note_entry_layer:Load()
        if note_entry_layer:IsEmpty() then
            local note_entry_cell = cell:CreateNoteEntryCell(true, 0)
            if not note_entry_cell:IsEmpty() then
                local entry = note_entry_cell:AppendEntriesInLayer(layer, 1)
                entry:MakeRest()
                entry.Duration = finale.WHOLE_NOTE
                entry.Legality = true
                note_entry_cell:Save()
            end
            local measure = finale.FCMeasure()
            measure:Load(cell_measure)
            local measure_dur = measure:GetDuration()
            local measure_region = finale.FCMusicRegion()
            measure_region:SetStartMeasure(cell_measure)
            measure_region:SetEndMeasure(cell_measure)
            measure_region:SetStartStaff(cell_staff)
            measure_region:SetEndStaff(cell_staff)
            for entry in eachentrysaved(measure_region) do
                if measure_dur ~= finale.WHOLE_NOTE and entry.LayerNumber == layer then
                    local tuplet = finale.FCTuplet()
                    tuplet:PrefsReset()
                    tuplet:SetReferenceDuration(measure_dur)
                    tuplet:SetSymbolicDuration(finale.WHOLE_NOTE)
                    tuplet:SetSymbolicNumber(1)
                    tuplet:SetReferenceNumber(1)
                    tuplet:SetNoteEntry(entry)
                    tuplet:SetShapeStyle(finale.TUPLETSHAPE_NONE)
                    tuplet:SetHorizontalOffset(-20)
                    tuplet:SetVisible(false)
                    tuplet:SaveNew()
                end
            end
        end
    end
end
layer_add_whole_rest_tuplet(region, 1)
layer_add_whole_rest_tuplet(region, 2)