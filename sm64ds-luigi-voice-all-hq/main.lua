-- name: Super Mario 64 DS Luigi Voice (ALL HQ)
-- incompatible:
-- description: Replaces Luigi's voice with the voices from Super Mario 64 DS.\nUses \\#ff6b91\\SMS Alfredo's\\#dcdcdc\\ Voice mod as a template (Permission is given for anyone to use the code)\nThis verison of the mod uses High Quality versions of the voice clips if avaliable. If they're not avaliable, other applicable voice clips, from games of the same era are used.'

--Define what triggers the custom voice
local function use_custom_voice(m)
    return m.character.type == CT_LUIGI --Put your condition here!
end

--How many snores the sleep-talk has, or rather, how long the sleep-talk lasts
--If you omit the sleep-talk you can ignore this
local SLEEP_TALK_SNORES = 8

--Makes every other pant not play so it sounds more-ish like in DS. Makes a larger delay than whats in DS but it works...
local CANT_PANT = true
--Define what actions play what voice clips
--If an action has more than one voice clip, put those clips inside a table
--CHAR_SOUND_SNORING3 requires two or three voice clips to work properly...
--but you can omit it if your character does not sleep-talk
local CUSTOM_VOICETABLE = {
    [CHAR_SOUND_ATTACKED] = 'Ooh!.ogg',
--     [CHAR_SOUND_COUGHING1] = 'none',
--     [CHAR_SOUND_COUGHING2] = 'none',
--     [CHAR_SOUND_COUGHING3] = 'none',
--     [CHAR_SOUND_DOH] = 'none',
    [CHAR_SOUND_DROWNING] = 'Death.ogg',
    [CHAR_SOUND_DYING] = 'Death.ogg',
    [CHAR_SOUND_EEUH] = 'Pull Up.ogg',
--     [CHAR_SOUND_GAME_OVER] = 'none',
    [CHAR_SOUND_GROUND_POUND_WAH] = 'Hah!.ogg',
    [CHAR_SOUND_HAHA] = 'All Right.ogg',
--    [CHAR_SOUND_HAHA_2] = 'falling-burning.mp3', --test audio because Im not sure if this actually exists. UPDATE: It exists, but ds luigi has no noise for this so im commenting it out
    -- [CHAR_SOUND_HELLO] = 'none',
    [CHAR_SOUND_HERE_WE_GO] = 'Luigi4.ogg',
    [CHAR_SOUND_HOOHOO] = 'Haiyah!.ogg',
    [CHAR_SOUND_HRMM] = 'Uh.ogg',
    -- [CHAR_SOUND_IMA_TIRED] = 'none',
    [CHAR_SOUND_LETS_A_GO] = 'ChrSel Ok.ogg',
    [CHAR_SOUND_MAMA_MIA] = 'Blublegh!.ogg',
    [CHAR_SOUND_OKEY_DOKEY] = {'Yah-hoo.ogg','Oh yeah.ogg'},
    [CHAR_SOUND_ON_FIRE] = 'Burning-mockup.mp3',
    [CHAR_SOUND_OOOF] = 'Ooh!.ogg',
    [CHAR_SOUND_OOOF2] = 'Ooh!.ogg',
    [CHAR_SOUND_PANTING] = 'Haah.ogg', --Can use some random pitch changes, Too bad I don't know how to add that :D
--     [CHAR_SOUND_PANTING_COLD] = 'none',
    -- [CHAR_SOUND_PRESS_START_TO_PLAY] = 'none',
    [CHAR_SOUND_PUNCH_HOO] = 'Oh yeah.ogg',
    [CHAR_SOUND_PUNCH_WAH] = {'Eeyah!.ogg','Heh!.ogg'},
    [CHAR_SOUND_PUNCH_YAH] = {'Eeyah!.ogg','Heh!.ogg'},
    [CHAR_SOUND_SNORING1] = 'snore1.mp3',
    [CHAR_SOUND_SNORING2] = 'snore2.mp3',
    -- [CHAR_SOUND_SNORING3] = {'snore1.mp3', 'snore2.mp3'},
    [CHAR_SOUND_SO_LONGA_BOWSER] = 'Luigi8.ogg',
    [CHAR_SOUND_TWIRL_BOUNCE] = 'Woohooo!.ogg',
--     [CHAR_SOUND_UH] = 'none',
    [CHAR_SOUND_UH2] = 'Hah!.ogg',
--     [CHAR_SOUND_UH2_2] = 'none',
    [CHAR_SOUND_WAAAOOOW] = 'Falling Scream.ogg',
    [CHAR_SOUND_WAH2] = 'Yah!.ogg',
    [CHAR_SOUND_WHOA] = 'Woo!.ogg',
    [CHAR_SOUND_YAHOO] = 'Yah-hoo.ogg',
    [CHAR_SOUND_YAHOO_WAHA_YIPPEE] = 'Haiyah!.ogg',
    [CHAR_SOUND_YAH_WAH_HOO] = {'Ho.ogg','Yah!.ogg'},
    [CHAR_SOUND_YAWNING] = 'Hmm.ogg'
}

--Define the table of samples that will be used for each player
--Global so if multiple mods use this they won't create unneeded samples
--DON'T MODIFY THIS SINCE IT'S GLOBAL FOR USE BY OTHER MODS!
gCustomVoiceSamples = {}
gCustomVoiceStream = nil

--Get the player's sample, stop whatever sound
--it's playing if it doesn't match the provided sound
--DON'T MODIFY THIS SINCE IT'S GLOBAL FOR USE BY OTHER MODS!
--- @param m MarioState
function stop_custom_character_sound(m, sound)
    local voice_sample = gCustomVoiceSamples[m.playerIndex]
    if voice_sample == nil or not voice_sample.loaded then
        return
    end

    audio_sample_stop(voice_sample)
    if voice_sample.file.relativePath:match('^.+/(.+)$') == sound then
        return voice_sample
    end
--     audio_sample_destroy(voice_sample)
end

--Play a custom character's sound
--DON'T MODIFY THIS SINCE IT'S GLOBAL FOR USE BY OTHER MODS!
--- @param m MarioState
function play_custom_character_sound(m, voice)
    --Get sound, if it's a table, get a random entry from it
    local sound
    if type(voice) == "table" then
        sound = voice[math.random(#voice)]
    else
        sound = voice
    end
    if sound == nil then return 0 end

    --Get current sample and stop it
    local voice_sample = stop_custom_character_sound(m, sound)

    --If the new sound isn't a string, let's assume it's
    --a number to return to the character sound hook
    if type(sound) ~= "string" then
        return sound
    end

    --Load a new sample and play it! Don't make a new one if we don't need to
    if (m.area == nil or m.area.camera == nil) and m.playerIndex == 0 then
        if gCustomVoiceStream ~= nil then
            audio_stream_stop(gCustomVoiceStream)
            audio_stream_destroy(gCustomVoiceStream)
        end
        gCustomVoiceStream = audio_stream_load(sound)
        audio_stream_play(gCustomVoiceStream, true, 1)
    else
        if voice_sample == nil then
            voice_sample = audio_sample_load(sound)
        end
        audio_sample_play(voice_sample, m.pos, 1)

        gCustomVoiceSamples[m.playerIndex] = voice_sample
    end
    return 0
end

--Main character sound hook
--This hook is freely modifiable in case you want to make any specific exceptions
--- @param m MarioState
local function custom_character_sound(m, characterSound)
    if not use_custom_voice(m) then return end
    if characterSound == CHAR_SOUND_SNORING3 then return 0 end
    if characterSound == CHAR_SOUND_HAHA and m.hurtCounter > 0 then return 0 end
    
    local voice = CUSTOM_VOICETABLE[characterSound]
    if voice ~= nil then
        if characterSound == CHAR_SOUND_PANTING then
            if CANT_PANT then
                CANT_PANT = false
                return 0
            else
                CANT_PANT = true
            end
        elseif characterSound == CHAR_SOUND_YAH_WAH_HOO and m.action == ACT_WALL_KICK_AIR then
            return play_custom_character_sound(m, "Yah-hoo.ogg")
        elseif characterSound == CHAR_SOUND_WAAAOOOW and m.action == ACT_SHOCKED then
            return play_custom_character_sound(m, "Ow!.ogg")
        elseif characterSound == CHAR_SOUND_YAHOO_WAHA_YIPPEE and m.action == ACT_TRIPLE_JUMP then
            return play_custom_character_sound(m, {"Yah-hoo.ogg"})
        elseif characterSound == CHAR_SOUND_WAH2 and m.action == ACT_HEAVY_THROW then
            return play_custom_character_sound(m, {"Hah!.ogg"}) --It'd be real silly of me if CHAR_SOUND_WAH2 is simply only for throwing a heavy object, and this if statement is useless. But I have no clue if thats the case, the google sheet gives almost no info for CHAR_SOUND_WAH2
        end

        return play_custom_character_sound(m, voice)
    end
    return 0
end
hook_event(HOOK_CHARACTER_SOUND, custom_character_sound)

--Snoring logic for CHAR_SOUND_SNORING3 since we have to loop it manually
--This code won't activate on the Japanese version, due to MARIO_MARIO_SOUND_PLAYED not being set
local SNORE3_TABLE = CUSTOM_VOICETABLE[CHAR_SOUND_SNORING3]
local STARTING_SNORE = 46
local SLEEP_TALK_START = STARTING_SNORE + 49
local SLEEP_TALK_END = SLEEP_TALK_START + SLEEP_TALK_SNORES

--Main hook for snoring
--- @param m MarioState
local function custom_character_snore(m)
    if not use_custom_voice(m) then return end

    --Stop the snoring!
    if m.action ~= ACT_SLEEPING then
        if m.isSnoring > 0 then
            stop_custom_character_sound(m)
        end
        return

    --You're not in deep snoring
    elseif not (m.actionState == 2 and (m.flags and MARIO_MARIO_SOUND_PLAYED) ~= 0) then
        return
    end

    local animFrame = m.marioObj.header.gfx.animInfo.animFrame

    --Behavior for CHAR_SOUND_SNORING3
    if SNORE3_TABLE ~= nil and #SNORE3_TABLE >= 2 then
        --Exhale sound
        if animFrame == 2 and m.actionTimer < SLEEP_TALK_START then
            play_custom_character_sound(m, SNORE3_TABLE[2])

        --Inhale sound
        elseif animFrame == 25 then
            
            --Count up snores
            if #SNORE3_TABLE >= 3 then
                m.actionTimer = m.actionTimer + 1

                --End sleep-talk
                if m.actionTimer >= SLEEP_TALK_END then
                    m.actionTimer = STARTING_SNORE
                end
    
                --Enough snores? Start sleep-talk
                if m.actionTimer == SLEEP_TALK_START then
                    play_custom_character_sound(m, SNORE3_TABLE[3])
                
                --Regular snoring
                elseif m.actionTimer < SLEEP_TALK_START then
                    play_custom_character_sound(m, SNORE3_TABLE[1])
                end
            
            --Definitely regular snoring
            else
                play_custom_character_sound(m, SNORE3_TABLE[1])
            end
        end

    --No CHAR_SOUND_SNORING3, just use regular snoring
    elseif animFrame == 2 then
        play_character_sound(m, CHAR_SOUND_SNORING2)

    elseif animFrame == 25 then
        play_character_sound(m, CHAR_SOUND_SNORING1)
    end
end
hook_event(HOOK_MARIO_UPDATE, custom_character_snore)
