local m=peripheral.wrap("top") 
local control= peripheral.find("tweaked_controller")
----------------------------------
local Ag={       --俯仰，偏航，横滚角
    yaw=0,  
    pitch=0,
    roll=0
}               
local quat={    --四元数
    w=0,
    x=0,
    y=0,
    z=0

}                  
-------------------------------------
local Pid={              --基本参数

    p_pitch = 0,            --比例
    p_roll  = 0,

    i_pitch = 0,            --积分
    i_roll  = 0,

    d_pitch = 0,            --微分
    d_roll  = 0
}

local Error_table={      --误差参数
    pitch = 0,
    roll  = 0,
    yaw   = 0,
}

local expected_vale={    --期望参数
    pitch = 0,
    roll  = 0,
    yaw   = 0,

}

local output_power={      --输出参数

    pitch    =0,
    roll     =0


}
function GetEuler()                          --姿态获取（四元数->欧拉角）

    quat.w=ship.getQuaternion().w
    quat.x=ship.getQuaternion().y
    quat.y=ship.getQuaternion().x
    quat.z=ship.getQuaternion().z
    Ag.yaw=math.deg(math.atan2(quat.y*quat.z+quat.w*quat.x,1/2-(quat.x*quat.x+quat.y*quat.y)))
    Ag.pitch=math.deg(math.atan2(quat.x*quat.y+quat.w*quat.z,1/2-(quat.y*quat.y+quat.z*quat.z)))
    Ag.roll=math.deg(math.asin(-2*(quat.x*quat.z-quat.w*quat.y)))
end


function Error_calc()
    GetEuler()
    Error_table.pitch = expected_vale.pitch - Ag.pitch 
    Error_table.roll  = expected_vale.roll  - Ag.roll  -- 修正这里
end

function PID_Contorl_P()
     while true  do
        output_power.pitch1 = 0
        output_power.roll2 = 0
    GetEuler()
    Error_calc()
    Pid.p_pitch = math.floor(Error_table.pitch * 10)
    Pid.d_pitch = Error_table.pitch * 10000
    Pid.i_pitch = 200000
    

    Pid.p_roll  = math.floor(Error_table.roll * 10)
    Pid.d_roll  = Error_table.roll * 10000
    Pid.i_roll  = 200000
   

    if control.getAxis(1)~=-1 and control.getAxis(1)~=1  and control.getAxis(2)~=-1 and control.getAxis(2)~=1 then
        
    
          if Ag.pitch>0 or Ag.pitch<0 then
                 
                output_power.pitch1 = (output_power.pitch1 +  Pid.i_pitch * Pid.p_pitch -Pid.d_pitch)
                m.applyRotDependentTorque(0,0,output_power.pitch1) 
                print(Pid.d_pitch,Pid.i_pitch,Pid.p_pitch)
                print(output_power.pitch1)
                print(Ag.pitch)
                if Ag.pitch==0 then
                     output_power.pitch1 = 0
                    end
              
            end

            if Ag.roll<0 or Ag.roll>0 then
                
                output_power.roll2 = (output_power.roll2 +  Pid.i_roll * Pid.p_roll -Pid.d_roll)
                m.applyRotDependentTorque(output_power.roll2,0,0) 
                print(Pid.d_pitch,Pid.i_pitch,Pid.p_pitch)
                print(output_power.pitch1)
                print(Ag.pitch)
                if Ag.roll==0 then
                    output_power.roll2 = 0
                end
                
            end

           
        
       end
        os.sleep(0)
    end
end



    while true do
        GetEuler()                             
        PID_Contorl_P()
        os.sleep(0.1)  -- 调整 sleep 时间
    end