import { useState } from "react";
import { Button, SelectInput, SimpleForm, BulkUpdateButton } from "react-admin";
import type { BulkUpdateButtonProps } from "react-admin";

const sexChoices = [
    { id: "Male", name: "Male" },
    { id: "Female", name: "Female" },
    { id: "unknown", name: "unknown" },
];

export const BulkEditSexButton = (props: Omit<BulkUpdateButtonProps, "data">) => {
    const [open, setOpen] = useState(false);
    const [sex, setSex] = useState("");

    const handleOpen = () => setOpen(true);

    const handleSubmit = () => {
        setOpen(false);
    };

    return (
        <>
            <Button label="Set Bulk Edit" onClick={handleOpen} />
            {open && (
                <div style={{
                    position: "fixed",
                    top: 0,
                    left: 0,
                    width: "100vw",
                    height: "100vh",
                    background: "rgba(0,0,0,0.3)",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    zIndex: 1000
                }}>
                    <div style={{ background: "white", padding: 24, borderRadius: 8, minWidth: 300 }}>
                        <SimpleForm
                            onSubmit={(values: Record<string, any>) => {
                                setSex(values.sex);
                                handleSubmit();
                            }}
                            defaultValues={{ sex }}
                        >
                            <SelectInput source="sex" choices={sexChoices} label="Sex" />
                        </SimpleForm>
                    </div>
                </div>
            )}
            {sex && (
                <BulkUpdateButton {...props} data={{ sex }} label="Apply Bulk Sex" onClick={() => setSex("")} />
            )}
        </>
    );
};
