//
//  TrafficServices.swift
//  MapConcept
//
//  Created by Igor Bragança Toledo on 31/01/25.
//

import Foundation

struct SPTransServices {
    private let baseURL = "https://api.olhovivo.sptrans.com.br/v2.1"
    private let token = "e1f897f645d73e66d1547efd5a4acd03f698701f8488867145776a1c394bcf20"
    
    func getBusLinesInfo() async throws -> [BusLinesInfoSP] {
            // Lógica para fazer a requisição à API e retornar os dados
            // Exemplo fictício
            let url = URL(string: "SUA_URL_AQUI")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([BusLinesInfoSP].self, from: data)
            return response
        }
    
    // Pega a localização dos ônibus por linha
    func getBusPositionSP(busNumber: String) async throws -> [BusPositionSP] {
        guard let encodedBusNumber = busNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/Posicao/Linha?codigoLinha=\(encodedBusNumber)") else {
            print("Error: Invalid Bus Line -> \(busNumber)")
            throw BusSPError.invalidBusID
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Error: Invalid HTTP Status Code -> \(String(describing: response))")
            throw BusSPError.invalidURL
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Resposta da API: \(jsonString)")
        }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw BusSPError.invalidData
            }
            
            guard let vsData = json["vs"] as? [[String: Any]] else {
                if let vsEmpty = json["vs"] as? [Any], vsEmpty.isEmpty {
                    return []
                }
                throw BusSPError.invalidData
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            var busPositions: [BusPositionSP] = []
            for vehicleData in vsData {
                do {
                    let vehicleDataData = try JSONSerialization.data(withJSONObject: vehicleData)
                    let vehicle = try decoder.decode(BusPositionSP.self, from: vehicleDataData)
                    busPositions.append(vehicle)
                } catch {
                    print("Erro ao decodificar veículo individual:", error)
                }
            }
            
            return busPositions
        } catch {
            print("Erro ao processar JSON:", error)
            throw BusSPError.invalidData
        }
        
        return []
    }
    
    
    
    
    //Pega as informações das linhas de ônibus
    func getBusLineSP(busNumber: String) async throws -> [BusLineSP] {
        guard let encodedBusNumber = busNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/Linha/Buscar?termosBusca=\(encodedBusNumber)") else {
            print("Error: Invalid URL -> \(baseURL)/Linha/Buscar?termosBusca=\(busNumber)")
            throw BusSPError.invalidURL
        }
        
        print("URL gerada: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Erro: Invalid HTTP Response -> \(response)")
            throw BusSPError.invalidURL
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([BusLineSP].self, from: data)
        } catch {
            print("Erro ao decodificar JSON: \(error)")
            throw BusSPError.invalidData
        }
    }
    
    
    
    
    //Autenticação do Token de acesso
    func autenticar(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/Login/Autenticar?token=\(token)") else {
            print("Erro ao criar URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erro na autenticação:", error.localizedDescription)
                completion(false)
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                print("Erro: Dados não encontrados ou resposta inválida")
                completion(false)
                return
            }
            
            if httpResponse.statusCode == 200, let responseString = String(data: data, encoding: .utf8) {
                print("Resposta da API: \(responseString)")
                completion(responseString.contains("true"))
            } else {
                print("Falha na autenticação: Status code \(httpResponse.statusCode)")
                completion(false)
            }
        }
        task.resume()
    }
    
}









