--[[
Code from Sumi, Age of Mending
License: MIT
--]]
local pmb_muskets = {}


function pmb_muskets.get_eyepos(player)
    local eyepos = vector.add(player:get_pos(), vector.multiply(player:get_eye_offset(), 0.1))
    eyepos.y = eyepos.y + player:get_properties().eye_height
    return eyepos
end

function pmb_muskets.do_particles(pos, n)
    local va = 0.2
    local vv = 3
    local vl = 5

    local p_velo = 0.15

    n = n or 5
    for i = 1, n do
        minetest.add_particle({
            pos = vector.offset(pos, (math.random() * va)-va/2, (math.random() * va)-va/2, (math.random() * va)-va/2),
            velocity = vector.new(((math.random()-p_velo)*vl)^vv,((math.random()-p_velo)*vl)^vv,((math.random()-p_velo)*vl)^vv),
            expirationtime = (math.random()*0.1)+0.0,
            size = math.random() * 3,
            collisiondetection = false,
            vertical = false,
            texture = "Spark.png^[colorize:#ffff99:255",
            glow = 14,
        })
    end
end
function pmb_muskets.do_smoke_particles(p, n, dir, size, dist)
    local va = (size or 2) / 10
    local vv = 32 / 15
    -- error("\n".."p value is "..dump(p).."\n".."dir value is "..dump(dir))
    for i = 1, n do
        local pos = vector.add(p, vector.multiply(dir, i*(dist or 0.2)))
        minetest.add_particle({
            pos = vector.offset(pos, (math.random() * va)-va/2, (math.random() * va)-va/2, (math.random() * va)-va/2),
            velocity = vector.new((math.random()-0.5)*vv,(math.random()-0.5)*vv,(math.random()-0.5)*vv),
            expirationtime = math.random(0.3, 0.6),
            size = math.random(0.5, 1.25),
            collisiondetection = false,
            vertical = false,
            texture = "SmallSmoke.png^[opacity:100",
        })
    end
end


function pmb_muskets.apply_damage(gun_obj, obj)
    if not obj then
        --print("Tried to apply damage without a entity")        
        return
    end    

    local vel = gun_obj.object:get_velocity()

    obj:punch(gun_obj._shooter, 1.0, 
        {
            full_punch_interval = 1.0,
            damage_groups = gun_obj._damage,
        }, 
        vector.normalize(vel))

        --print("---------------")
        --print(km_dump(obj:get_armor_groups()))
end


minetest.register_entity("komet_mod:musket_shot_entity", {
    initial_properties = {
        physical = false,
        textures = {"orange_tracer.png"},
        visual = "mesh",
        visual_size = {x=0.25, y=0.25},
        mesh = "tracer.obj",
        collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2,},
        use_texture_alpha = true,
        pointable = false,
    },
    _timer = 0,
    _last_pos = false,
    _shooter = nil,
    _dir = nil,
    _speed = 200,
    _lifetime = 1,
    _damage = {fleshy = 1},
    _flags = {init = true},
    _bullet_drop = 0,
    damage_groups = {fleshy = 1},
    on_step = function(self, dtime, moveresult)
        self._timer = self._timer + dtime
        local pos = self.object:get_pos()
        if not self._dir then return end
        if (not self._last_pos) then
            self._last_pos = pos
            self.object:set_velocity(vector.multiply(self._dir, self._speed))
            return
        end
        local vel = self.object:get_velocity()
        vel = vector.multiply(vel, 0.97)
        vel.y = vel.y + dtime * self._bullet_drop
        self.object:set_velocity(vel)

        local collided = false
        local ray = minetest.raycast(self._last_pos, pos, true, false)
        -- local ray = minetest.raycast(vector.add(pos), pos, true, false)
        local obj
        
        for pointed_thing in ray do
            if pointed_thing.type == "node" then
                local node = minetest.get_node(pointed_thing.under)
                local def = minetest.registered_nodes[node.name]

                if def and def.walkable then
                    collided = true
                    pos = pointed_thing.intersection_point
                    self.object:set_pos(pos)
                
                    break
                end
         
            elseif pointed_thing.type == "object" and pointed_thing.ref ~= self._shooter then
                obj = pointed_thing.ref
                local ent = obj:get_luaentity()
                
                if ent and ent._invulnerable then
                    break
                end

                pos = pointed_thing.intersection_point
                self.object:set_pos(pos)

                break
            end
        end
        


        if obj then
            if obj:get_luaentity() and obj:get_luaentity().is_mob then
                pmb_muskets.apply_damage(self, obj)
            end
        end


        if not collided and obj then
            collided = true
        end


        if self._timer > self._lifetime then self.object:remove() self._removed = false end
        if collided and not self._removed then

            pmb_muskets.do_particles(pos, 10)
            pmb_muskets.do_smoke_particles(pos, 10, vector.normalize(vector.multiply(vel, -2)))
            self._removed = true
            self.object:remove()
            return
        end
        self._last_pos = self.object:get_pos()
    end
})
