import React from "react";
export function EvidencePanel({ evidence }) {
    return (
        <div>
            <h3>Evidence Locker</h3>
            {evidence.map(item => (
                <div key={item.id}>
                    <span>{item.type}</span>
                    <span>{item.location}</span>
                    <span>{item.collected_by}</span>
                    <span>{item.description}</span>
                </div>
            ))}
        </div>
    );
}