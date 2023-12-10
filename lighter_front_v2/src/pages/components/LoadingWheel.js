import './LoadingWheel.css'
const LoadingWheel = ({text}) => {
    return (

        <>
            <div className="loadingOverlay">
                <div className="loadingTab">
                    {text}
                    <div className="loading-wheel-container">
                        <div className="loading-wheel">
                            <div></div>
                            <div></div>
                            <div></div>
                        </div>
                    </div>
                </div>
            </div>
        </>

    );
};
export default LoadingWheel;