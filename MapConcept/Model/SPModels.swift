//
//  SPModel.swift
//  MapConcept
//
//  Created by Igor Bragança Toledo on 03/02/25.
//


// ---------- Ônibus - São Paulo ----------
struct BusResponseSP: Codable {
    var hr: String // Horário de referência da geração das informações
    var l: [BusLinesInfoSP]? //  Relação de linhas localizadas
}

struct BusLinesInfoSP: Codable {
    var c: String // Letreiro Completo
    var cl: Int // ID da linha
    var sl: Int // Sentido de operação onde 1 significa de TP para TS e 2 de TS para TP
    var lt0: String // Letreiro de destino da linha
    var lt1: String // Letreiro de origem da linha
    var qv: Int // Quantidade de veículos localizados
    var vs: [BusPositionSP]
}

struct BusPositionSP: Codable {
    var p: String // Prefixo do veículo (agora é String)
    var a: Bool // Acessível
    var ta: String // Horário universal (UTC)
    var py: Double // Latitude
    var px: Double // Longitude
    var sv: String? // Serviço (opcional)
    var `is`: String? // Is (opcional)
}


// ---------- Linhas de Ônibus - São Paulo ----------
struct BusLineSP: Codable {
    var cl: Int // ID da linha
    var lc: Bool // Se uma linha opera no modo circular
    var lt: String // Informa a primeira parte do letreiro numérico da linha
    var tl: Int // Informa a segunda parte do letreiro numérico da linha
    var sl: Int //Informa o sentido da linha
    var tp: String // Informa o letreiro descritivo sentido terminal primário
    var ts: String // Informa o letreiro descritivo sentido terminal secundário
}


// ---------- Paradas de ônibus - São Paulo ----------
struct BusStopsSP: Codable {
    var cp: Int //ID da parada
    var np: String //Nome da parada
    var ed: String // Endereço da parada
    var py: Double // Latitude da parada
    var px: Double // Longitude da parada
}
