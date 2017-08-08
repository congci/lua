--路由配置


return {
    -- m站的路由
    msite = {
        {
            url        = '^/api/dynamic$',
            mob        = "play.play",
            action     = "dynamic",
            -- params     = {"vid"}
        },
    --pc的路由
    pc   = {
        {
            url        = "api/play",
            mob        = "play.play",
            action     = "play"
        }

    }


        
    }
    


}