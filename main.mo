import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Time "mo:base/Time";
import Iter "mo:base/Iter";

actor DroneSwarmSystem {
  // Koordinat yapısı
  type Coordinate = {
    latitude : Float;
    longitude : Float;
    altitude : Float;
  };

  // Drone veri yapısı
  type DroneData = {
    id : Text;
    location : Coordinate;
    payloadType : Text;
    payloadWeight : Float;
    batteryLevel : Float;
    timestamp : Time.Time;
  };

  // Drone'ların saklanacağı HashMap
  let drones = HashMap.HashMap<Text, DroneData>(10, Text.equal, Text.hash);

  // Yeni bir drone eklemek için fonksiyon
  public func addDrone(
    id : Text, 
    latitude : Float, 
    longitude : Float, 
    altitude : Float,
    payloadType : Text,
    payloadWeight : Float,
    batteryLevel : Float
  ) : async () {
    let newDrone : DroneData = {
      id = id;
      location = {
        latitude = latitude;
        longitude = longitude;
        altitude = altitude;
      };
      payloadType = payloadType;
      payloadWeight = payloadWeight;
      batteryLevel = batteryLevel;
      timestamp = Time.now()
    };
    drones.put(id, newDrone);
    Debug.print("Drone " # id # " added to the swarm");
  };

  // Belirli bir drone'un konumunu güncellemek için fonksiyon
  public func updateDroneLocation(
    id : Text, 
    latitude : Float, 
    longitude : Float, 
    altitude : Float
  ) : async () {
    switch (drones.get(id)) {
      case (null) { 
        Debug.print("Drone not found"); 
      };
      case (?existingDrone) {
        let updatedDrone : DroneData = {
          existingDrone with 
          location = {
            latitude = latitude;
            longitude = longitude;
            altitude = altitude;
          };
          timestamp = Time.now()
        };
        drones.put(id, updatedDrone);
        Debug.print("Drone " # id # " location updated");
      };
    };
  };

  // Tüm drone'ların listesini almak için fonksiyon
  public query func getAllDrones() : async [DroneData] {
    let droneIterator = drones.entries();
    var droneList : [DroneData] = [];
    
    for ((key, drone) in droneIterator) {
      droneList := Array.append(droneList, [drone]);
    };
    
    return droneList;
  };

  // Belirli bir drone'un bilgilerini almak için fonksiyon
  public query func getDroneById(id : Text) : async ?DroneData {
    drones.get(id)
  };

  // Belirli bir yük tipine sahip drone'ları filtrelemek için fonksiyon
public query func getDronesByPayloadType(payloadType : Text) : async [DroneData] {
  let allDrones = Iter.toArray(drones.entries());
  let filteredDrones = Array.filter<(Text, DroneData)>(
    allDrones,
    func((_, drone)) { drone.payloadType == payloadType }
  );
  return Array.map<(Text, DroneData), DroneData>(filteredDrones, func((_, drone)) { drone });
};


  // Drone'ların toplam yük miktarını hesaplamak için fonksiyon
  public query func getTotalPayloadWeight() : async Float {
    let allDrones = Iter.toArray(drones.entries());
    Array.foldLeft<(Text, DroneData), Float>(
      allDrones,
      0.0,
      func(acc, (_, drone)) { acc + drone.payloadWeight }
    )
  };
};
