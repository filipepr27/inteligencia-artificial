class Jet{
    constructor(x,y,width,height,
                arenaheight,arenawidth,padding,
                controlType,maxSpeed=3,color="lightBlue",
                score=100,prologID=-1,name="Humano",
                timeForUpdateProlog=100){
        this.x=x;
        this.y=y;
        this.width=width;
        this.height=height;
        this.name=name;
        this.color=color;

        this.prologID=prologID;
        this.arenaleft = padding;
        this.arenatop = padding;
        this.arenawidth = arenawidth - padding;
        this.arenaheight = arenaheight - padding;

        this.speed=0.3;
        this.acceleration=0.05;
        this.maxSpeed=maxSpeed;
        this.friction=0.05;
        this.angle=0;
        this.controlType=controlType;
        this.steps=0;
        this.smallSteps=0;
        this.damage=false;
        this.sensor=new Sensor(this);
        this.score=score;
        this.lastDamage = Date.now();

        this.alreadyDrawed = false;

        this.controls=new Controls(controlType,timeForUpdateProlog);
        this.polygon=this.#createPolygon();

        [this.img, this.mask] = this.#getJetImg(color);
        [this.img2, this.mask2] = this.#getJetImg("black");
    }

    #getJetImg(color) {
        var img=new Image();
        // https://commons.wikimedia.org/wiki/File:Lockheed_YF-22_Lightning_II_3-view.svg
        img.src = (this.controlType == "DUMMY")?"airplane_dummy.png":"airplane.png";

        var mask=document.createElement("canvas");
        mask.width=this.width;
        mask.height=this.height;
        
        const maskCtx=mask.getContext("2d");
        img.onload=()=>{
            maskCtx.fillStyle=color;
            maskCtx.rect(0,0,this.width,this.height);
            maskCtx.fill();

            maskCtx.globalCompositeOperation="destination-atop";
            maskCtx.drawImage(img,0,0,this.width,this.height);
        }
        return [img, mask];
    }

    update(arenaBorders,jets,booms){
        if (this.score > 0){
            switch(this.controlType) {
                case "PROLOG":
                    this.controls.updateProlog(this.getSensors(), this.x, this.y, this.angle, this.prologID, this.score, this.speed);
                    break
                case "DUMMY":
                    this.controls.updateDUMMYKeys(this.getSensors());
                    break;
                case "KEYS":
                    //console.log(this.getSensors());
                    break;
            }
            this.#move();
        } else {
            this.img = this.img2;
            this.mask = this.mask2;
        }
        this.polygon=this.#createPolygon();
        if (this.#assessDamage(arenaBorders,jets)) {
            this.damage = true;
            this.#collision();
        }else{
            this.damage = false;
        }
        if (this.#boomDamage(booms)) {
            this.score=(this.score-10>0)?this.score-10:0;
        }
        if(this.sensor){
            this.sensor.update(arenaBorders,jets,booms);
        }

        let boom = this.controls.getBOOM() && (this.score > 0);
        return [boom, this.x, this.y, this.angle];
    }

    getSensors() {
        if(this.sensor){
            const offsets=this.sensor.readings.map(
                s=>s==null?0:1-s.offset
            );
            return offsets;
        }else{
            return new Array(this.sensor.rayCount).fill(0);
        }
    }

    #boomDamage(booms){
        for (let i=0;i<booms.length;i++) {
            if (polysIntersect(this.polygon, booms[i].getCircle())) {
                booms[i].deactivate();
                return true;
            }
        }
        return false;
    }

    #assessDamage(arenaBorders,jets){
        for(let i=0;i<arenaBorders.length;i++){
            if(polysIntersect(this.polygon,arenaBorders[i])){
                return true;
            }
        }
        /*for(let i=0;i<jets.length;i++){
            if(polysIntersect(this.polygon,jets[i].polygon)){
            //if (this.checkCollisionPixelPerfect(jets[i])) {
                return true;
            }
        }*/
        if (this.x < 0 || this.y < 0 ||
            this.x > this.arenawidth || this.y > this.arenaheight) {
            this.score = 0;
        }
        return false;
    }

    #createPolygon(){
        const points=[];
        const rad=Math.hypot(this.width,this.height)/2;
        const alpha=Math.atan2(this.width,this.height);
        points.push({
            x:this.x-Math.sin(this.angle-alpha)*rad,
            y:this.y-Math.cos(this.angle-alpha)*rad
        });
        points.push({
            x:this.x-Math.sin(this.angle+alpha)*rad,
            y:this.y-Math.cos(this.angle+alpha)*rad
        });
        points.push({
            x:this.x-Math.sin(Math.PI+this.angle-alpha)*rad,
            y:this.y-Math.cos(Math.PI+this.angle-alpha)*rad
        });
        points.push({
            x:this.x-Math.sin(Math.PI+this.angle+alpha)*rad,
            y:this.y-Math.cos(Math.PI+this.angle+alpha)*rad
        });
        return points;
    }

    #move(){
        if(this.controls.forward){
            this.speed = Math.min(this.speed+this.acceleration, this.maxSpeed);
        }
        if(this.controls.reverse && !this.damage){
            this.speed = Math.max(this.speed-this.acceleration, 0.3);
        }

        if(this.speed>this.maxSpeed){
            this.speed=this.maxSpeed;
        }

        if(this.speed<0.3){
            this.speed=0.3;
        }

        if(this.speed!=0){
            const flip=this.speed>0?1:-1;
            if(this.controls.left){
                this.#updateAngle(this.angle+0.03*flip);
            }
            if(this.controls.right){
                this.#updateAngle(this.angle-0.03*flip);
            }
        }
        
        this.x-=Math.sin(this.angle)*this.speed;
        this.y-=Math.cos(this.angle)*this.speed;
    }

    #updateAngle(newAngle) {
        newAngle = newAngle % (Math.PI*2);
        if (newAngle < 0) newAngle = Math.PI*2 + newAngle;
        this.angle = newAngle;
    }

    #collision() {
        if (this.score <= 0) return;
        var oldSpeed = this.speed, sensors, inc=1.5;
        const flip=this.speed>0?1:-1;
        if(this.controls.left){
            this.#updateAngle(this.angle+0.03*flip);
        }
        if(this.controls.right){
            this.#updateAngle(this.angle-0.03*flip);
        }
        sensors = this.getSensors();
        for (var i=0;i<sensors.length-1;i++)
            if (sensors[i] > 0.8) this.speed = -0.2;
        this.x-=Math.sin(this.angle)*this.speed*inc;
        this.y-=Math.cos(this.angle)*this.speed*inc;
        inc = 0.01;
        this.speed = (oldSpeed>0)?oldSpeed*inc:oldSpeed*inc;
        if ((Date.now()-this.lastDamage) > 1000) {
            this.score=(this.score-2>0)?this.score-2:0;
            this.lastDamage = Date.now();
        }
    }

    draw(ctx, drawSensor = false) {
        this.alreadyDrawed = true;
        ctx.save();
        ctx.translate(this.x, this.y);
        ctx.rotate(-this.angle);

        const baseTilt = 0.3; // Fator base de inclinação das asas
        const speedFactor = this.speed; // Limita a intensidade máxima
        const tiltFactor = Math.max(-baseTilt, Math.min(baseTilt, (this.controls.right - this.controls.left) * baseTilt * speedFactor));
        const verticalScale = 0.8; // Escala vertical constante
        const shear = tiltFactor; // Cisalhamento baseado no tilt

        // Aplicar transformação personalizada
        ctx.transform(1, shear, 0, verticalScale, 0, 0);

        // Desenho da máscara e da imagem
        ctx.drawImage(this.mask, -this.width/2, -this.height/2, this.width, this.height);
        ctx.globalCompositeOperation = "multiply";
        ctx.drawImage(this.img, -this.width/2, -this.height/2, this.width, this.height);

        ctx.restore();
        ctx.save();
        ctx.translate(this.x, this.y);
        ctx.rotate(-this.angle);
        ctx.fillStyle = (this.score > 20)?"black":"red";
        ctx.font = "bold 10px Arial";
        ctx.strokeStyle = "white";
        ctx.lineWidth = 1;
        ctx.strokeText('' + this.score, -this.width/4, this.height/4);
        ctx.fillText('' + this.score, -this.width/4, this.height/4);
        ctx.restore();

        // Desenho dos sensores, se necessário
        if (this.sensor && drawSensor) {
            this.sensor.draw(ctx);
        }
    }



}
