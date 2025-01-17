//// não mexa nessas linhas:
// Imagem do céu: https://www.pickpik.com/atmosphere-beautiful-blue-blue-sky-bright-cloudiness-96746
var windowHeight = $(window).height(), windowWidth = $(window).width(), lastUpdateScore = Date.now(), prologJetIDs = 0, timeForUpdatingProlog = 200;
const canvas = document.getElementById("myCanvas");
canvas.width = 800;//windowWidth;
canvas.height = 600;//windowHeight;
const ctx = canvas.getContext("2d"), background = new Image();
background.src = 'sky.jpg';
const dummyTunkNames = /*from chatGPT*/["Boladão", "Rabugento", "Trovão", "Bagunceiro", "Marrento", "Trambiqueiro", "Espertinho", "Sorriso", "Soneca", "Maluco", "Zé Bala", "Trapalhão", "Fofinho", "Dengoso", "Terremoto", "Estabanado", "Cuspidor de Fogo", "Doidivanas", "Trovador", "Curioso", "Esquentadinho", "Pestinha", "Trapaceiro", "Esperto", "Relâmpago", "Roncador", "Surpresa", "Malandrinho", "Borbulhante", "Folgado", "Trovão Azul", "Espião", "Explosivo", "Cabeça de Vento", "Malabarista", "Tristonho", "Saltitante", "Dorminhoco", "Felpudo", "Arrasador", "Espirra-Água", "Trapaceiro", "Esquentado", "Reluzente", "Fofoqueiro", "Torpedo", "Dente de Leão", "Terrível", "Sapeca", "Bate-Papo", "Barulhento", "Faísca", "Linguarudo", "Abobalhado", "Bagunceiro", "Furacão", "Tagarela", "Artilheiro", "Engraçadinho", "Furioso", "Bicudo", "Mágico", "Espanta-Mosquito", "Ziguezague", "Estiloso", "Brincalhão", "Trancado", "Bagunçado", "Sorridente", "Tornado", "Desastrado", "Malabarista", "Mala Sem Alça", "Borbulhante", "Dorminhoco", "Trovão Azul", "Risadinha", "Bagunceiro", "Barulhento", "Fofinho", "Sorriso Largo", "Reluzente", "Esperto", "Arrepiante", "Mexeriqueiro", "Estelar", "Roncador", "Zigzag", "Fanfarrão", "Bate-Papo", "Trapaceiro", "Estourado", "Espirra-Água", "Bagunceiro", "Bagunça", "Trovador", "Saltitante", "Cabeça de Vento", "Veloz"];
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//// Essa área pode ser configurada por você, mas aconselho não trocar o maxSpeed, arenaPadding e tamanho dos jatos.
const maxSpeed = 2, arenaPadding = 10, jetW = 50, jetH = 30,
    score = 100, // vida de cada jato
    dummyJets = 10, // quantidade de jatos aleatórios
    keysJet = false, // modifique para ter um jato controlado pelo teclado
    // nome dos jatos controlados por Prolog (obs.: tem que adaptar o servidor.pl ao mexer aqui)
    // a quantidade é referente a quantidade de nomes, na falta de criatividade, o nome pode repetir... rs
    // exemplos de dois:
    //prologJets=["Ligerin", "ApagaFogo"], // se quiser colocar dois jatos proloog, faça assim
    prologJets = ["Ligerin"], // escolha aqui o nome de seu jato controlado por prolog
    //prologJets=[], //se não quiser nenhum jato prolog, faça assim
    showSensors = true, //modifique para mostrar os sensores dos jatos PROLOG e KEYS
    showSensorsOfDummyJets = false; //modifique para mostrar os sensores dos jatos DUMMY
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//// Não mexa daqui para baixo:
const arena = new Arena(canvas.height, canvas.width, arenaPadding), _colors = new Colors(0);
var jets = [];
if (keysJet) jets.push(newJet("KEYS"));
for (let i = 0; i < prologJets.length; i++) jets.push(newJet("PROLOG"));
for (let i = 0; i < dummyJets; i++) jets.push(newJet("DUMMY"));

var allBOOMS = new Array(), lastBullet = new Array(jets.length);
for (let i = 0; i < lastBullet.length; i++) lastBullet[i] = 0;

animate();

// controls: ["DUMMY", "KEYS", "PROLOG"]
function newJet(controls = "DUMMY") {
    let pos = getPosition(), name, id = -1;
    switch (controls) {
        case "PROLOG":
            name = prologJets[prologJetIDs];
            id = prologJetIDs++;
            break;
        case "DUMMY":
            name = dummyTunkNames[Math.round(Math.random() * dummyTunkNames.length) % dummyTunkNames.length];
            break;
        case "KEYS":
            name = "Humano";
            break;
    }
    return new Jet(pos.x, pos.y, jetH, jetW,
        canvas.height, canvas.width,
        arenaPadding, controls, maxSpeed,
        _colors.getColor(), score,
        (controls == "PROLOG") ? id : -1,
        name, timeForUpdatingProlog);
}

function getPosition() {
    let jetPadding = arenaPadding + Math.max(jetH, jetW);
    let x = parseInt(Math.random() * (canvas.width - jetPadding * 2) + jetPadding),
        y = parseInt(Math.random() * (canvas.height - jetPadding * 2) + jetPadding);
    return { x: x, y: y };
}

function getScores() {
    let ret = { scores: new Array(jets.length), winner: undefined }, aux;
    aux = 0;
    for (let i = 0; i < jets.length; i++) {
        ret.scores[i] = jets[i].score;
        if (jets[i].score > 0)
            if (aux++ == 0) ret.winner = i;
            else ret.winner = undefined;
    }
    return ret;
}

function updateScoresDiv(scores) {
    let e = $('#id_score');
    e.empty();
    if (scores.winner != undefined) {
        $('#id_winner').text("Vencedor: Jato " + scores.winner +
            " (" + jets[scores.winner].name + "," + jets[scores.winner].controlType + ")");
        $('#id_km').hide();
    } else {
        lastUpdateScore = Date.now();
        for (let i = 0; i < scores.scores.length; i++) {
            e.append('<label style="color:' + jets[i].color + ';">' + jets[i].name + ': ' + scores.scores[i] + '</label>');
        }
    }
}

$('#kmdiv').toggle();
updateScoresDiv(getScores());
document.addEventListener("keydown", function (event) {
    switch (event.key) {
        case "s":
            $('#kmdiv').toggle();
            break;
    }
});

function updateCanvas() {
    // Updating booms (removing deactivted ones)
    var newBooms = new Array();
    for (let i = 0; i < allBOOMS.length; i++) {
        if (!allBOOMS[i].deactivated)
            newBooms.push(allBOOMS[i]);
    }
    allBOOMS = newBooms;

    // Updating jets
    for (let i = 0; i < jets.length; i++) {
        // Jets list :
        let newJets = new Array();
        for (let j = 0; j < jets.length; j++) {
            if (i != j) newJets.push(jets[j]);
        }
        // For each jet, it will check the other jets and bombs
        boom = jets[i].update(arena.borders, newJets, allBOOMS);
        // If it goes more than 1000 milliseconds after the last bomb, it can fire again
        if (boom[0] && Math.abs(lastBullet[i] - Date.now()) > 1000) {
            let bomb = new Boom(boom[1], boom[2], boom[3], Math.max(jetH, jetW));
            lastBullet[i] = Date.now();
            allBOOMS.push(bomb);
        }
    }
    // bombs update:
    for (let i = 0; i < allBOOMS.length; i++) {
        allBOOMS[i].update(arena.position);
    }
}

function animate() {
    var scores = getScores();
    var runFinished = scores.winner != undefined;
    if ((Date.now() - lastUpdateScore) > 1000)
        updateScoresDiv(scores);

    updateCanvas();

    ctx.save();
    arena.draw(ctx, background);
    //ctx.drawImage(background, 10, 10, canvas.width-20, canvas.height-20);
    for (let i = 0; i < jets.length; i++) {
        if (jets[i].controlType == "DUMMY")
            jets[i].draw(ctx, showSensorsOfDummyJets);
        else
            jets[i].draw(ctx, showSensors);
    }
    for (let i = 0; i < allBOOMS.length; i++) {
        if (allBOOMS[i] != undefined)
            allBOOMS[i].draw(ctx);
    }

    ctx.restore();

    var newJets = new Array();
    for (let i = 0; i < jets.length; i++) {
        if (jets[i].score > 0) newJets.push(jets[i]);
    }
    jets = newJets;

    if (runFinished) {
        scores = getScores();
        updateScoresDiv(scores);
        updateScoresDiv = function () { };
        $('#kmdiv').show();
    } else {
        requestAnimationFrame(animate);
    }
}
