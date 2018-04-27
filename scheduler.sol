pragma solidity ^0.4.0;

contract Scheduler{
    
    struct Job {
        uint8 id;
        uint payment;
        uint time;
        address requestor;
        uint8 result;
        uint queuePosition;
        uint status;
    }
    
    Job[] jobList;
    uint8[] freeMap;
    uint8 idCounter;
    
    mapping (uint8 => Job) public idToJob;
    
   constructor(uint8 _queueSize) public {
        jobList.length = _queueSize;
        freeMap.length = _queueSize;
        for (uint i = 0; i < freeMap.length; i++) {
            freeMap[i] = 0;
        }
    }
    
    // setting freeMap to 1 means the job needs to be served
    function addJob(uint payment, uint time) public returns (uint){
        for (uint i = 0; i < freeMap.length; i++) {
            if (freeMap[i] == 0) {
                jobList[i].id = idCounter++;
                jobList[i].payment = payment;
                jobList[i].time = time;
                jobList[i].requestor = msg.sender;
                jobList[i].status = 1;
                jobList[i].queuePosition = i;
                freeMap[i] = 1;
                idToJob[jobList[i].id] = jobList[i];
                return jobList[i].id;
            }
        }
        return uint(-1);
    }
    
    // setting freemap to 2 means the job is being served
    function acquireJob() public returns (int){
        for (uint i = 0; i < freeMap.length; i++) {
            if (freeMap[i] == 1) {
                uint8 _id = jobList[i].id;
                idToJob[_id].status = 2;
                freeMap[i] = 2;
                return int(i);
            }
        }
        return -1;
    }
    
    // setting freemap to 0 means that there is no job
    function completeJob(uint8 _id, uint8 result) public {
        uint id = idToJob[_id].queuePosition;
        freeMap[id] = 0;
        idToJob[_id].status = 3;
        idToJob[_id].result = result;
        jobList[id] = Job({queuePosition : id,
                            status : 0,
                            result: 0,
                            requestor: msg.sender,
                            time: 0,
                            payment: 0,
                            id : 0
        });
    }
    
    function jobStatus(uint8 _id) public view returns (uint) {
        return idToJob[_id].status;
    }
    
    function jobResult(uint8 _id) public view returns (int) {
        return idToJob[_id].result;
    }
    
}