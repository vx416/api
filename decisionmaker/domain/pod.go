package domain

// PodProcess represents a process information within a pod
type PodProcess struct {
	PID     int    `json:"pid"`
	Command string `json:"command"`
	PPID    int    `json:"ppid,omitempty"`
}

// PodInfo represents pod information with associated processes
type PodInfo struct {
	PodName     string       `json:"pod_name"`
	Namespace   string       `json:"namespace"`
	PodUID      string       `json:"pod_uid"`
	ContainerID string       `json:"container_id,omitempty"`
	Processes   []PodProcess `json:"processes"`
}

type Intent struct {
	PodID         string            `json:"podID,omitempty"`
	NodeID        string            `json:"nodeID,omitempty"`
	K8sNamespace  string            `json:"k8sNamespace,omitempty"`
	CommandRegex  string            `json:"commandRegex,omitempty"`
	Priority      int               `json:"priority,omitempty"`
	ExecutionTime int64             `json:"executionTime,omitempty"`
	PodLabels     map[string]string `json:"podLabels,omitempty"`
}
